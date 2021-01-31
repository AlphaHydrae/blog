module PostsPagePlugin
  class PostPageGenerator < Jekyll::Generator
    safe true

    def generate(site)
      site.pages << PostsPage.new(site: site)
    end
  end

  # Subclass of `Jekyll::Page` with custom method definitions.
  class PostsPage < Jekyll::Page
    def initialize(site:)
      @site = site

      # Path to the source directory.
      @base = site.source

      # Direcory the page will reside in.
      @dir = 'posts'

      # All pages have the same filename.
      @basename = 'index'
      @ext = '.html'
      @name = 'index.html'

      all_posts = site.posts.docs
      today = all_posts.reduce({}) do |memo,post|
        if today_type = post.data.fetch('today', {})['type']
          memo[today_type] ||= []
          memo[today_type] << post
        end
        memo
      end

      featured = [ 'found', 'learned', 'wrote' ]
      today_posts = today.reduce([]){ |memo,(today_type,posts)| memo + posts }
      featured_today_posts = today_posts.select{ |post| featured.include?(post.data['today']['type']) }

      @data = {
        'layout' => 'posts',
        'featured' => featured,
        'today' => today,
        'remaining_posts' => all_posts - featured_today_posts
      }
    end
  end
end
