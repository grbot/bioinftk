#!/usr/bin/env python3                                          
import subprocess
import argparse
import sys
import os

def main():
    usage = "usage: -v VCF_FILE -o SAMPLE_SEX_FILE [-t TMP_DIR]"
    parser = argparse.ArgumentParser(description=usage)
    parser.add_argument("-v", "--vcf", dest="vcf_file", required=True, help="Single or multisample VCF.")
    parser.add_argument("-o", "--out", dest="out_file", required=True, help="Contains a list of samples and their sex.")
    parser.add_argument("-t", "--tmp", dest="tmp_dir", default="/tmp", help="Temporary directory for intermediate files.")
    args = parser.parse_args()

    if not args.vcf_file:
        print ("(-v VCF_FILE)")
        return -1
    if not args.out_file:
        print ("(-o SAMPLE_SEX_FILE)")
        return -2    
    
    vcf_file = args.vcf_file
    out_file = args.out_file
    tmp_dir = args.tmp_dir
    sample_list = get_samples_from_vcf(vcf_file)
    print(f"Samples in VCF: {sample_list}")
    for sample in sample_list:
        sample_vcf_file = os.path.join(tmp_dir, f"{sample}.vcf.gz")
        extract_sample_from_vcf(vcf_file, sample, sample_vcf_file)
        get_bcftools_stats(sample_vcf_file, f"{sample_vcf_file}.stats")
        hetero, homo, ratio = calculate_hetero_homo_ratio(f"{sample_vcf_file}.stats")
        print(f"Sample: {sample}, Heterozygous: {hetero}, Homozygous: {homo}, Ratio: {ratio}")

def get_samples_from_vcf(vcf_file):
    """
    Get a list of samples from a VCF file using bcftools.

    :param vcf_file: Path to the input VCF file.
    :return: List of sample names.
    """
    command = [
        "bcftools", "query",
        "--list-samples",
        vcf_file
    ]
    result = subprocess.run(command, capture_output=True, text=True, check=True)
    samples = result.stdout.strip().split('\n')
    return samples

def extract_sample_from_vcf(vcf_file, sample_name, output_file):
    """
    Extract a sample from a multisample VCF file using bcftools.

    :param vcf_file: Path to the input VCF file.
    :param sample_name: Name of the sample to extract.
    :param output_file: Path to the output VCF file.
    """
    command = [
        "bcftools", "view", 
        "--samples", sample_name,
        "--output-file", output_file,
        "--output-type", "z",
        vcf_file
    ]
    subprocess.run(command, check=True)

def get_bcftools_stats(vcf_file, output_file):
    """
    Get bcftools stats for a VCF file.

    :param vcf_file: Path to the input VCF file.
    :param output_file: Path to the output stats file.
    """
    command = [
        "bcftools", "stats",
        "--output", output_file,
        vcf_file
    ]
    subprocess.run(command, check=True)

def calculate_hetero_homo_ratio(vcf_file_stats):
    """
    Calculate the heterozygous and homozygous counts and their ratio from a VCF file.

    :param vcf_file: Path to the input VCF file.
    :return: Tuple containing heterozygous count, homozygous count, and their ratio.
    """
    command = f"bcftools query -f '%CHROM\\t%POS\\t[%GT]\\n' {vcf_file_stats} | awk -F '\\t' '{{split($3, genotypes, \"/\"); if (genotypes[1] != genotypes[2]) hetero++;else homo++;}}END{{print hetero, homo, hetero / homo}}'"
    result = subprocess.run(command, shell=True, capture_output=True, text=True, check=True)
    hetero, homo, ratio = result.stdout.strip().split()
    return int(hetero), int(homo), float(ratio)

if __name__ == "__main__":
    main()