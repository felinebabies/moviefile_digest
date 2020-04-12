require 'bundler'
Bundler.require

require 'optparse'
require 'yaml'

require_relative 'digest_catalog_generator.rb'

# 探査する対象のディレクトリ一覧
$inputdirlist = []

# 出力先ディレクトリ
$outputdir = ""

$inputrecursive = false

opt = OptionParser.new

$optionerror = false

$extensionlist = [
    "mp4",
    "mov"
]

def setoutputpath(outdir)
    if outdir then
        if Dir.exist?(outdir) then
            $outputdir = outdir
        else
            STDERR.puts "指定されたディレクトリ[ #{indir} ]は存在しません。"
            $optionerror = true
        end
    end
end

def setinputpath(indir)
    if Dir.exist?(indir) then
        $inputdirlist << indir
    else
        STDERR.puts "指定されたディレクトリ[ #{indir} ]は存在しません。"
        $optionerror = true
    end
end

def setextension(ext)
    $extensionlist << ext
    $extensionlist.uniq!
end

# 設定ファイルから設定を読み込む
def parseconfigfile(cnffilepath)
    confdata = YAML.load_file(cnffilepath)

    setoutputpath(confdata['out'])

    if confdata['in'] then
        if confdata['in'].instance_of?(Array) then
            confdata['in'].each do |i|
                setinputpath(i)
            end
        else
            setinputpath(confdata['in'])
        end
    end

    if cnffilepath['recursive'] then
        $inputrecursive = true
    end

    if confdata['extension'] then
        if confdata['extension'].instance_of?(Array) then
            confdata['extension'].each do |i|
                setextension(i)
            end
        else
            setextension(confdata['extension'])
        end
    end
end

opt.on('-o', '--out OUTPUTDIR', 'specify the output directory') do |outdir|
    setoutputpath(outdir)
end

opt.on('-i', '--in INPUTDIR', 'specify the input directory') do |indir|
    setinputpath(indir)
end

opt.on('-r', '--recursive', 'recursively explore the input directory') do
    $inputrecursive = true
end

opt.on('-e', '--extension EXTENSION', 'add an extension to search for') do |ext|
    setextension(ext)
end

opt.on('-c', '--config CONFIGFILE', 'specify the configuration file') do |cnffilepath|
    if File.exist?(cnffilepath) then
        parseconfigfile(cnffilepath)
    else
        STDERR.puts "指定されたファイル[ #{cnffilepath} ]は存在しません。"
        $optionerror = true
    end
end


opt.parse(ARGV)

if $optionerror then
    exit(false)
end

if $outputdir.empty? then
    STDERR.puts "出力先ディレクトリを指定してください。"
    exit(false)
end

if $inputdirlist.empty? then
    STDERR.puts "入力ディレクトリを一つ以上指定してください。"
    exit(false)
end

dg = DigestCatalogGenerator.new

dg.generate($inputdirlist, $outputdir, $inputrecursive, $extensionlist)

