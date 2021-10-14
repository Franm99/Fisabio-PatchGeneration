import os

patches_dir = "Recortes/"


def count_patches():
    counter = 0
    contajes = os.listdir(patches_dir)
    for contaje in contajes:
        patches = os.listdir(patches_dir + contaje)
        counter += len(patches)
    return counter


if __name__ == '__main__':
    print(count_patches())  # 2241
