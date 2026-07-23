to-gif() {
    # Based on https://gist.github.com/SheldonWangRJT/8d3f44a35c8d1386a396b9b49b43c385
    output_file="$1.gif"

    ffmpeg -i $1 -pix_fmt rgb8 -r 10 $output_file && gifsicle -O3 $output_file -o $output_file
}
