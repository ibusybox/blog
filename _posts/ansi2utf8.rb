
def txt2md src_file_path, dest_file_path, head
  File.open src_file_path, "r:GBK" do |f|
    src_str = f.read
    #dest_str = converter.convert src_str
    File.open dest_file_path, 'w:UTF-8' do |wf|
      wf.write head
      wf.write src_str
    end
  end
end

def build_head file_name
  title = file_name.split('.').first
  head = "---\nlayout: post\ntitle: #{title}\n---\n"
  return head
end


source_encoding = 'GBK'
dest_encoding = 'UTF-8'
dest_path = "/Users/mao/Desktop/Mao/workspace/space_md"
src_path = "/Users/mao/Desktop/Mao/workspace/SPACE"


Dir.new(src_path).each do |file_name|
  #file_name = file_name.force_encoding('UTF-8')
  puts "start process #{file_name}"

  if file_name.end_with? 'txt'
    src_file = "#{src_path}/#{file_name}"
    puts "convert #{src_file}"
    time = File.stat(src_file).mtime

    dest_file = "#{dest_path}/#{time.year}-#{time.mon}-#{time.day}-#{file_name.split('.').first}.md"

    txt2md src_file, dest_file, build_head(file_name)
  end
end

