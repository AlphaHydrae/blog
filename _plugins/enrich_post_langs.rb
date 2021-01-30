module EnrichPostLangs
  class Generator < Jekyll::Generator
    def generate(site)
      site.posts.docs.each do |post|
        EnrichPostLangs.add_post_langs(site, post)
      end
    end
  end

  def self.add_post_langs(site, post)
    site_langs = site.data['langs'].keys
    post_tags = post.data['tags'] || []
    post_lang_versions = post.data['versions'] || {}

    post_langs = post_tags.intersection(site_langs)
    post.data['langs'] = post_langs.empty? ? post_lang_versions.keys : post_langs
  end
end
