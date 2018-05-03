#!/usr/bin/env python3

''' Create a BagIt directory from a DSpace export zip

Run: `ds2bi.py DSPACE_ZIPFILE [OUTPUT_DIR]`
 e.g. ds2bi.py weatherstation.zip /tmp
'''

import sys
import os
import zipfile
import collections
import datetime
import json
from lxml import etree
import bagit

def main(argv=None):
    '''Main function
    Args:
        argv[1] (str): Name of Dspace zipfile
        argv[2] (str, optional): Output path, defaults to '.'
    Returns:
        None
'''
    if argv is None:
        argv = sys.argv
    zipfilename = argv[1]
    out_dir = argv[2] if len(argv) > 2 else '.'
    base = os.path.splitext(os.path.basename(zipfilename))[0]
    stage_dir = os.path.join(out_dir, base)
    stage_unzipped(zipfilename, stage_dir)
    with open(os.path.join(stage_dir, 'mets.xml'), 'rb') as metsfile:
        mets_xml_str = metsfile.read()
    mets_data = parse_mets(mets_xml_str)
    rename_files(stage_dir, mets_data['files'])
    bagit_data = make_bagit_data(mets_data)
    delete_unused_files(stage_dir, bagit_data['files'])
    make_bag(stage_dir, bagit_data)

# ---- File staging and cleanup ----

def stage_unzipped(zipfilename, stage_dir):
    '''Unzip file to a specified directory'''
    os.mkdir(stage_dir)
    with zipfile.ZipFile(zipfilename, 'r') as myzip:
        zipfile.ZipFile.extractall(myzip, stage_dir)

def rename_files(stage_dir, name_map):
    '''Rename files in directory by old_name->new_name hash'''
    for old_name, new_name in name_map.items():
        old_path = os.path.join(stage_dir, old_name)
        new_path = os.path.join(stage_dir, new_name)
        os.rename(old_path, new_path)

def delete_unused_files(stage_dir, known_files):
    '''Delete unused Dspace files (thumbnails, etc.)'''
    known = set(known_files)
    for filename in os.listdir(stage_dir):
        if filename in known:
            continue
        os.remove(os.path.join(stage_dir, filename))

# ---- METS.XML parsing ----

def parse_mets(mets_xml_str):
    '''Retrieve data from mets file for creating DRUW item'''
    root = etree.fromstring(mets_xml_str)
    field_elems = get_field_elems(root)
    params = get_params(field_elems)
    file_mappings = get_file_mappings(root)
    return {
        'params': params,
        'files': file_mappings,
    }

def get_field_elems(root):
    '''Get all fields elements in a XML'''
    current_type = root.get('TYPE')[7:]
    if current_type != 'ITEM':
        raise RuntimeError('Cannot handle collections yet')
    xpath = "//dim:dim[@dspaceType='{}']/dim:field".format(current_type)
    namespaces = {'dim': 'http://www.dspace.org/xmlns/dspace/dim'}
    return root.xpath(xpath, namespaces=namespaces)

def get_params(field_elems):
    '''Get select DRUW item parameters from XML elements'''
    attributes = {
        'dc.title': 'title',
        'dc.contributor.author': 'creator',
    }

    default_params = {
        'rights_statement': ['No Known Copyright'],
        'visibility': 'open',
        'keyword': [],
        'date_uploaded': datetime.date.today().isoformat(),
    }
    params = collections.defaultdict(list)
    for elem in field_elems:
        field = construct_attribute_name(elem)
        if field in attributes:
            params[attributes[field]].append(elem.text)
    params.update(default_params)
    return params

def construct_attribute_name(element):
    '''Make name for hash lookup'''
    field = element.get('mdschema') + '.' + element.get('element')
    if element.get('qualifier') != None:
        field = field + '.' + element.get('qualifier')
    return field

def get_file_mappings(root):
    '''Get DSpace bitstream->filename hash'''
    namespaces = {'premis': 'http://www.loc.gov/standards/premis'}
    file_mappings = []
    file_md5_list = root.xpath('//premis:object', namespaces=namespaces)
    for file_elem in file_md5_list:
        ttype, bitstream, original_filename = get_filename_mapping(file_elem, root)
        if ttype in ['ORIGINAL', 'TEXT']:
            file_mappings.append([bitstream, original_filename])
    return dict(file_mappings)

def get_filename_mapping(file_elem, root):
    '''Get single bitstream->orig_filename mapping'''
    checksum = get_checksum(file_elem)
    orig_filename = get_orig_filename(file_elem)
    ttype, bitstream_filename = get_bitstream_filename(checksum, root)
    return [ttype, bitstream_filename, orig_filename]

def get_checksum(file_elem):
    '''Get the checksum of a file'''
    namespaces = {'premis': 'http://www.loc.gov/standards/premis'}
    xpath = 'premis:objectCharacteristics/premis:fixity/premis:messageDigest'
    return file_elem.find(xpath, namespaces=namespaces).text

def get_orig_filename(file_elem):
    '''Get the of a bitstream artifact'''
    namespaces = {'premis': 'http://www.loc.gov/standards/premis'}
    return file_elem.find('premis:originalName', namespaces=namespaces).text

def get_bitstream_filename(checksum, root):
    '''Get the type of original file and its bitstream name'''
    xpath = "//mets:file[@CHECKSUM='{}']/mets:FLocat".format(checksum)
    new_file = root.xpath(xpath, namespaces={'mets': 'http://www.loc.gov/METS/'})
    ttype = new_file[0].getparent().getparent().get('USE')
    filename = new_file[0].get('{http://www.w3.org/1999/xlink}href')
    return [ttype, filename]

# ---- BagIt ----

def make_bagit_data(mets_data):
    '''Add attachable files to passed in METS data'''
    files = []
    for new_name in mets_data['files'].values():
        files.append(new_name)
    mets_data['files'] = files
    return mets_data

def make_bag(stage_dir, bagit_data):
    '''Create a BagIt directory with all data inserted within'''
    add_metadata_file(stage_dir, bagit_data['params'])
    bagit.make_bag(stage_dir)

def add_metadata_file(stage_dir, params):
    '''Add a DRUW metadata file to a BagIt directory'''
    metadata_file = os.path.join(stage_dir, 'druw-metadata.json')
    with open(metadata_file, 'w') as metadatafile:
        json.dump(params, metadatafile)

if __name__ == '__main__':
    sys.exit(main())
