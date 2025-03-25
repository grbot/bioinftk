#!/usr/bin/env python3                                          
import argparse
import sys
import os
import concurrent.futures
import threading
import pysam

lock = threading.Lock()

def process_sample(sample, vcf_file, out_file):
    print("Calculate " + sample + " sex...")
    hetero, homo, ratio = calculate_hetero_homo_ratio(vcf_file, sample)
    print(f"Sample: {sample}, Heterozygous: {hetero}, Homozygous: {homo}, Ratio: {ratio}")
    if ratio < 0.01:
        sex = "male"
    elif 0.4 < ratio < 0.6:
        sex = "female"
    else:
        sex = "unknown"
    print(f"Sample: {sample}, Sex: {sex}")
    with lock:
        with open(out_file, 'a') as f:
            f.write(f"{sample}\t{sex}\t{homo}\t{hetero}\t{ratio}\n")

def main():
    usage = "usage: -v VCF_FILE -o SAMPLE_SEX_FILE [-n NUM_THREADS]"
    parser = argparse.ArgumentParser(description=usage)
    parser.add_argument("-v", "--vcf", dest="vcf_file", required=True, help="Single or multisample VCF.")
    parser.add_argument("-o", "--out", dest="out_file", required=True, help="Contains a list of samples and their sex.")
    parser.add_argument("-n", "--num_threads", dest="num_threads", type=int, default=1, help="Number of threads to use.")
    args = parser.parse_args()

    if not args.vcf_file:
        print ("(-v VCF_FILE)")
        return -1
    if not args.out_file:
        print ("(-o SAMPLE_SEX_FILE)")
        return -2    
    
    vcf_file = args.vcf_file
    out_file = args.out_file
    num_threads = args.num_threads
    sample_list = get_samples_from_vcf(vcf_file)
    print(f"Samples in VCF: {sample_list}")

    with concurrent.futures.ThreadPoolExecutor(max_workers=num_threads) as executor:
        futures = [executor.submit(process_sample, sample, vcf_file, out_file) for sample in sample_list]
        for future in concurrent.futures.as_completed(futures):
            future.result()

def get_samples_from_vcf(vcf_file):
    """
    Get a list of samples from a VCF file using pysam.

    :param vcf_file: Path to the input VCF file.
    :return: List of sample names.
    """
    vcf = pysam.VariantFile(vcf_file)
    return list(vcf.header.samples)

def calculate_hetero_homo_ratio(vcf_file, sample_name):
    """
    Calculate the heterozygous and homozygous counts and their ratio from a VCF file using pysam.

    :param vcf_file: Path to the input VCF file.
    :param sample_name: Name of the sample to calculate the ratio for.
    :return: Tuple containing heterozygous count, homozygous count, and their ratio.
    """
    vcf = pysam.VariantFile(vcf_file)
    hetero = 0
    homo = 0
    for record in vcf.fetch('chrX'):
        if sample_name in record.samples:
            gt = record.samples[sample_name]['GT']
            if gt[0] != gt[1]:
                hetero += 1
            else:
                homo += 1
    ratio = hetero / homo if homo != 0 else float('inf')
    return hetero, homo, ratio

if __name__ == "__main__":
    main()