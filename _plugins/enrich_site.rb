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
      # The list of available logos, deduced from the files in `_includes/logo`.
      @site.data['logos'] = self.logos

      # Add a `logo` key to all matching things (by name).
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
      # The `_archives` directory contains old posts from previous incarnations
      # of this site.
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

    # Things like programming languages, tools, etc are defined in the
    # `_data/things.yml` file and may be associated with a URL and logo for
    # pretty display.
    def add_post_things
      @post.data['featured_things'] = featured_things
      @post.data['tags'] = enriched_tags
      @post.data['extra_tags'] = tags - featured_things
    end

    # Enrich a post's tags with the versions referenced in its frontmatter.
    # Unless there are already tags mentioning some of the versions. In that
    # case, only those are used.
    def enriched_tags
      tags.intersection(versions.keys).empty? ? tags.union(versions.keys) : tags
    end

    def featured_things
      # Show things that have logos and are referenced in tags by default.
      featured = things_from_tags.intersection(site_logos)
      # If there are none, show things that have logos and are versioned in the
      # post's frontmatter.
      featured = things_from_versions.intersection(site_logos) if featured.empty? && things_from_tags.empty?
      featured
    end

    def site_logos
      @site.data['logos']
    end

    def site_thing_names
      @site.data['things'].keys
    end

    def tags
      @post.data.fetch('tags', [])
    end

    def things_from_tags
      tags.intersection(site_thing_names)
    end

    def things_from_versions
      versions.keys.intersection(site_thing_names)
    end

    def versions
      @post.data['versions'] || {}
    end
  end
end
