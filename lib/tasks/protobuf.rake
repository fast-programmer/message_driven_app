namespace :messages do
  task :recompile do
    Dir.glob('app/messages/*').each do |file|
      File.delete(file) if File.file?(file)
    end

    system 'protoc -I definitions/ --ruby_out=app/messages definitions/*'
  end
end
