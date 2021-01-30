module EnrichSite
  class Generator < Jekyll::Generator
    def generate(site)
      SiteEnricher.enrich(site: site)
    end
  end

  class SiteEnricher
    def self.enrich(**args)
      SiteEnricher.new(**args).apply
    end

    def initialize(site:)
      @site = site
    end

    def apply
      add_logos
      enrich_posts
    end

    private

    HTML_EXT = /\.html\z/
    LOGOS_DIRECTORY = File.expand_path(File.join(File.dirname(__FILE__), '..', '_includes', 'logo'))

    def add_logos
      @site.data['logos'] = self.logos
      @site.data['things'].keys.intersection(self.logos).each do |name|
        thing = @site.data['things'][name]
        thing['logo'] = name if self.logos.include?(name)
      end
    end

    def enrich_posts
      self.posts.each{ |post| PostEnricher.enrich(site: @site, post: post) }
    end

    def logos
      @logos ||= Dir.entries(LOGOS_DIRECTORY)
        .select{ |file| file.match(HTML_EXT) }
        .map{ |file| file.sub(HTML_EXT, '') }
    end

    def posts
      @site.collections['archives'].docs + @site.posts.docs
    end
  end

  class PostEnricher
    def self.enrich(**args)
      PostEnricher.new(**args).apply
    end

    def initialize(site:, post:)
      @site = site
      @post = post
    end

    def apply
      add_main_categories
      add_post_things
    end

    private

    def add_main_categories
      @post.data['main_categories'] = @post.data['categories']
        .reject{ |cat| cat.match(/\Atoday-/) }
    end

    def add_post_things
      site_thing_names = @site.data['things'].keys
      post_tags = @post.data['tags'] || []
      post_versions = @post.data['versions'] || {}

      post_things = post_tags.intersection(site_thing_names)
      post_things = post_versions.keys.intersection(site_thing_names) if post_things.empty?
      @post.data['things'] = post_things
      @post.data['tags'] = post_things.union(post_tags)
      @post.data['extra_tags'] = tags - post_things
    end

    def tags
      @post.data.fetch('tags', [])
    end
  end
end
