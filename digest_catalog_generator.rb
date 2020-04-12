require 'bundler'
Bundler.require

require 'pathname'
require 'digest/md5'

require_relative 'moviefile_digester'

# 指定した動画のダイジェストを掲載したカタログHTMLファイルを出力する
class DigestCatalogGenerator
    IMAGEDIR = "thumb"

    # カタログファイルを出力
    def generate(inputdirlist, destdir, inputrecursive)
        md = MoviefileDigester.new

        inputdirlist.each do |dir|
            # 指定ディレクトリ以下の対象ファイル全てを検出
            path = Pathname.new(dir)

            if inputrecursive then
                path += '**'
            end
            path += '*.{mp4,MP4}'
            
            moviefiles = Dir.glob(path)

            # 出力先ディレクトリを作る
            imgdirpath = Pathname.new(destdir)
            imgdirpath += IMAGEDIR
            Dir.mkdir(imgdirpath) unless Dir.exist?(imgdirpath)

            moviefiles.each do |mvpath|
                destpath = Pathname.new(destdir)
                destpath += IMAGEDIR
                destpath += Digest::MD5.hexdigest(File.expand_path(mvpath)) + ".gif"
                md.movie_to_gif(mvpath, destpath)
            end
        end

    end
end
