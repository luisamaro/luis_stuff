#!/usr/bin/env python3.7

import argparse
import os
import urllib.request
import ssl
import tarfile
import zipfile
import gzip
import shutil
import sys

# Download file from SFDC
def get_file(case_path,filename,url):
    ssl._create_default_https_context = ssl._create_unverified_context
    try:
        with open(f"{case_path}/{filename}", 'wb') as file:
            response = urllib.request.urlopen(url)
            data = response.read()
            file.write(data)
    except Exception as err:
        print(f"Error happened {err}")

# Uncompressed files
def uncompressed_file(case_path,filename):
    # For tar.gz
    try:
        with tarfile.open(f"{case_path}/{filename}", 'r:gz') as compressed_file:
            def is_within_directory(directory, target):
                
                abs_directory = os.path.abspath(directory)
                abs_target = os.path.abspath(target)
            
                prefix = os.path.commonprefix([abs_directory, abs_target])
                
                return prefix == abs_directory
            
            def safe_extract(tar, path=".", members=None, *, numeric_owner=False):
            
                for member in tar.getmembers():
                    member_path = os.path.join(path, member.name)
                    if not is_within_directory(path, member_path):
                        raise Exception("Attempted Path Traversal in Tar File")
            
                tar.extractall(path, members, numeric_owner=numeric_owner) 
                
            
            safe_extract(compressed_file, case_path)
        return 0
    except:
        a = None
    # For tar.xz
    try:
        with tarfile.open(f"{case_path}/{filename}", 'r:xz') as compressed_file:
            def is_within_directory(directory, target):
                
                abs_directory = os.path.abspath(directory)
                abs_target = os.path.abspath(target)
            
                prefix = os.path.commonprefix([abs_directory, abs_target])
                
                return prefix == abs_directory
            
            def safe_extract(tar, path=".", members=None, *, numeric_owner=False):
            
                for member in tar.getmembers():
                    member_path = os.path.join(path, member.name)
                    if not is_within_directory(path, member_path):
                        raise Exception("Attempted Path Traversal in Tar File")
            
                tar.extractall(path, members, numeric_owner=numeric_owner) 
                
            
            safe_extract(compressed_file, case_path)
        return 0
    except:
        a = None
    # For tar.bz2
    try:
        with tarfile.open(f"{case_path}/{filename}", 'r:bz2') as compressed_file:
            def is_within_directory(directory, target):
                
                abs_directory = os.path.abspath(directory)
                abs_target = os.path.abspath(target)
            
                prefix = os.path.commonprefix([abs_directory, abs_target])
                
                return prefix == abs_directory
            
            def safe_extract(tar, path=".", members=None, *, numeric_owner=False):
            
                for member in tar.getmembers():
                    member_path = os.path.join(path, member.name)
                    if not is_within_directory(path, member_path):
                        raise Exception("Attempted Path Traversal in Tar File")
            
                tar.extractall(path, members, numeric_owner=numeric_owner) 
                
            
            safe_extract(compressed_file, case_path)
        return 0
    except:
        a = None
    # For zip
    try:
        with zipfile.open(f"{case_path}/{filename}", 'rb') as compressed_file:
            def is_within_directory(directory, target):
                
                abs_directory = os.path.abspath(directory)
                abs_target = os.path.abspath(target)
            
                prefix = os.path.commonprefix([abs_directory, abs_target])
                
                return prefix == abs_directory
            
            def safe_extract(tar, path=".", members=None, *, numeric_owner=False):
            
                for member in tar.getmembers():
                    member_path = os.path.join(path, member.name)
                    if not is_within_directory(path, member_path):
                        raise Exception("Attempted Path Traversal in Tar File")
            
                tar.extractall(path, members, numeric_owner=numeric_owner) 
                
            
            safe_extract(compressed_file, case_path)
        return 0
    except:
        a = None
    # For gzip
    try:
        new = os.path.splitext(f"{case_path}/{filename}")
        with gzip.open(f"{case_path}/{filename}", 'rb') as compressed_file:
            with open(f"{case_path}/{new}", 'wb') as uncompressed_file:
                shutil.copyfileobj(uncompressed_file,compressed_file)
        return 0
    except:
        a = None
    return 1

# Main
# Argument parser
parser = argparse.ArgumentParser(description="Get support files from Salesfoce.com cases")
parser.add_argument('-c','--case', nargs=1, type=str, required=True, help='Case number/Customer name')
parser.add_argument('-u','--url', nargs=1, type=str, required=True, help='Support file URL')
parser.add_argument('-f','--force', action='store_true', required=False, help='Force (delete existing files/folders)')
parser.add_argument('-e', '--dont-extract',action='store_true', required=False, help="Don't extract downloaded files")
parser.add_argument('-d', '--dont-delete',action='store_true', required=False, help="Don't delete extracted files")
arguments = parser.parse_args()

case = arguments.case[0]
url = arguments.url[0]
base_path = "/Users/luis/work"
case_path = f"{base_path}/{case}"

filename = os.path.basename(str(arguments.url).split("?",1)[0])

if arguments.force:
    shutil.rmtree(f"{case_path}",ignore_errors=True)

if not os.path.isdir(case_path):
    os.mkdir(case_path)
    print(f"Folder {case_path} didn't exist. Created.")
if not os.path.isfile(f"{case_path}/{filename}"):
    get_file(case_path,filename,url)
    print(f"File {case_path}/{filename} didn't exist. Downloaded.")
if os.path.isfile(f"{case_path}/{filename}"):
    if not arguments.dont_extract:
        uncompressed_status = uncompressed_file(case_path,filename)
        if not uncompressed_status:
            print(f"File {case_path}/{filename} was uncompressed")
if not arguments.dont_delete and not arguments.dont_extract and not uncompressed_status:
    os.remove(f"{case_path}/{filename}")
    print(f"File {case_path}/{filename} was deleted")
