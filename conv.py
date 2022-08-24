import argparse
from pathlib import Path

import numpy as np
from PIL import Image
from sklearn.cluster import KMeans
from sklearn.utils import shuffle
from scipy.stats import mode


def quantise_image(image: np.ndarray) -> tuple[object, np.ndarray]:
    # Convert to a 2d array
    w, h, d = original_shape = tuple(image.shape)
    assert d == 3
    image_array = np.reshape(image, (w * h, d))

    image_array_sample = shuffle(image_array, random_state=0, n_samples=1_000)
    kmeans = KMeans(n_clusters=16, random_state=0).fit(image_array_sample)

    # Get labels for all points
    labels = kmeans.predict(image_array)

    return kmeans, labels.reshape(w, h)


def downsize_image(encoded: np.ndarray) -> np.ndarray:
    screen_res = np.array([81, 164])
    block_size = np.round(np.array(encoded.shape) / screen_res).astype(np.int32)

    cropped_size = (np.array(encoded.shape) / block_size).astype(np.int32) * block_size
    cropped = encoded[:cropped_size[0], :cropped_size[1]]

    x, y = cropped_size
    i, j = block_size

    subarrs = cropped.reshape(x // i, i, y // j, j).swapaxes(1, 2).reshape(-1, i * j)
    return np.array(mode(subarrs, keepdims=True, axis=-1))[0, :].reshape(x // i, y // j)


def save_all(filepath: Path, kmeans: object, image: np.ndarray):
    # Save the colour profile
    colours = kmeans.cluster_centers_.round().astype(np.int32)
    colours = np.apply_along_axis(lambda c: f"0x{c[0]:02X}{c[1]:02X}{c[2]:02X}", 1, colours)
    np.savetxt(filepath.with_name(f"{filepath.name}-colours").with_suffix(".txt"), colours, fmt="%s")

    output_filepath = filepath.with_suffix(".nfp")
    np.savetxt(output_filepath, image, fmt="%x", delimiter="")


def process_image(filepath: Path):
    # Open the image
    input_image = Image.open(filepath)
    rgb_image = input_image.convert("RGB")
    arr = np.asarray(rgb_image)
    kmeans, image = quantise_image(arr)
    image = downsize_image(image)
    save_all(filepath, kmeans, image)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("files", type=str, nargs="+", action="append")
    args = parser.parse_args()
    for file in args.files:
        process_image(file)


if __name__ == "__main__":
    main()
