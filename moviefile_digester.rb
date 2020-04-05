require 'bundler'
Bundler.require

class MoviefileDigester
    SEQUENCEIMAGEFORMAT = "screenshot_%d.jpg"

    def initialize()
        @ffmpegpath = "ffmpeg"
    end

    def ffmpegpath=(path)
        @ffmpegpath = path
    end

    # 動画を等間隔で連番画像化
    def movie_to_sequential(moviepath, destpath)
        movie = FFMPEG::Movie.new(moviepath)

        duration = movie.duration
        framerate = movie.frame_rate

        puts "duration = #{duration}"
        puts "framerate = #{framerate}"

        destname = File.join(destpath, SEQUENCEIMAGEFORMAT)

        `#{@ffmpegpath} -i "#{moviepath}" -filter:v fps=fps=0.1:round=down -s "480x270" "#{destname}"`
    end


    # 連番画像からgifアニメを作成
    def sequential_to_gif(sequensimgpath, destfilepath)

        sequensimgfilepath = File.join(sequensimgpath, SEQUENCEIMAGEFORMAT)

        `#{@ffmpegpath} -i "#{sequensimgfilepath}" -pix_fmt rgb24 -f gif -r 1 "#{destfilepath}"`
    end
end

