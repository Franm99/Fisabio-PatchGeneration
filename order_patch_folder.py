import os, shutil
from typing import Tuple
from tqdm import tqdm

DEST_PATH = "Recortes/"
SRC_PATH = "Tiras/"

# 1. Get xml files
# 2. Reorder "recortes" folder based on their root slice
# 3.

def get_xml_files(d: str = SRC_PATH) -> Tuple[dict, dict]:
    contajes = [i + '/' for i in os.listdir(d)]
    names_dict = dict()
    xml_dict = dict()
    for contaje in contajes:
        xml_names = [f for f in os.listdir(d+contaje) if f.endswith('.xml')]
        xml_dict[contaje] = xml_names
        names_dict[contaje] = [name[:-4] for name in xml_names]
    return xml_dict, names_dict


def reorder_dest_path(xml_dict, data_dict, d=DEST_PATH):
    contajes = [i + '/' for i in os.listdir(d)]
    for contaje in contajes:
        act_dir = d+contaje
        slice_names = data_dict[contaje]
        for name in tqdm(slice_names):
            if not os.path.isdir(act_dir+name):
                os.mkdir(act_dir+name)
            patches_from_slice = [i for i in os.listdir(act_dir) if (i.endswith('.png') and name in i)]
            for patch in tqdm(patches_from_slice, leave=False):
                shutil.move(act_dir+patch, act_dir+name+'/'+patch)


def move_xml_files(xml_dict, data_dict):
    for contaje in xml_dict.keys():
        for xml_name, filename in zip(xml_dict[contaje], data_dict[contaje]):
            dest_dir = DEST_PATH+contaje+filename+'/'+xml_name
            if not os.path.isfile(dest_dir):
                src_dir = SRC_PATH+contaje+xml_name
                if os.path.isfile(src_dir):
                    shutil.move(src_dir, dest_dir)


if __name__ == '__main__':
    xml_dirs, slices_names = get_xml_files()
    print(xml_dirs)
    # reorder_dest_path(xml_dirs, slices_names)
    move_xml_files(xml_dirs, slices_names)
