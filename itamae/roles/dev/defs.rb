def setup_filenames(prefix, platform, platform_version, postfix)
    return [
        prefix + '-' + platform + '-' + platform_version + postfix,
        prefix + '-' + platform + postfix,
        prefix + postfix,
    ]
end

def install(cookbook, files, cookbookdir)
    if cookbook.nil? || cookbook.empty? || files.nil? || files.empty? || cookbookdir.nil? || cookbookdir.empty?
        return
    end
    files.each do |filename|
        search_file = __dir__ + '/' + cookbookdir + '/' + cookbook + '/' + filename
        if File.exist? search_file
            puts cookbook + ': Found recipe: ' + filename
            include_recipe search_file
            return
        else
            puts cookbook + ': Not found: ' + filename
        end
    end
end
