require 'bundler'
Bundler.require

require 'pathname'
require 'digest/md5'

require_relative 'moviefile_digester'

# 指定した動画のダイジェストを掲載したカタログHTMLファイルを出力する
class DigestCatalogGenerator
    IMAGEDIR = "thumb"
    TEMPLATE_PATH = './view/template.haml'

    # HTMLファイルを出力
    def createhtml(thumbdata, destdir)
        htmlpath = Pathname.new(destdir)
        htmlpath += 'index.html'

        template = File.read(TEMPLATE_PATH)
        engine = Haml::Engine.new(template)
        htmldoc = engine.render(Object.new, :thumbdata => thumbdata)

        File.write(htmlpath, htmldoc)
    end

    # カタログファイルを出力
    def generate(inputdirlist, destdir, inputrecursive, extension)
        md = MoviefileDigester.new

        thumbdata = []

        inputdirlist.each do |dir|
            # 対応拡張子一覧を作成
            downcaseext = extension.map do |ext|
                ext.downcase
            end

            upcaseext = downcaseext.map do |ext|
                ext.upcase
            end

            extlist = downcaseext + upcaseext

            # 指定ディレクトリ以下の対象ファイル全てを検出
            path = Pathname.new(dir)

            if inputrecursive then
                path += '**'
            end
            path += "*.{#{extlist.join(',')}}"
            
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

                thumbdata << {
                    "origfile" => File.expand_path(mvpath),
                    "thumbfile" => destpath.relative_path_from(Pathname.new(destdir)).to_s
                }
            end
        end

        createhtml(thumbdata, destdir)

    end
end
