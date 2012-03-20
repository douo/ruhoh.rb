require 'pp'

class Ruhoh

  module Templaters
    
    module Helpers

      def partial(name)
        Ruhoh::DB.partials[name.to_s]
      end

      def raw_code(sub_context)
        code = sub_context.gsub('{', '&#123;').gsub('}', '&#125;').gsub('<', '&lt;').gsub('>', '&gt;')
        "<pre><code>#{code}</code></pre>"
      end
      
      def debug(sub_context)
        puts "=>DEBUG:"
        puts sub_context.class
        puts sub_context.inspect
        "<pre>#{sub_context.class}\n#{sub_context.pretty_inspect}</pre>"
      end

      def to_tags(sub_context)
        if sub_context.is_a?(Array)
          sub_context.map { |id|
            self.context['_posts']['tags'][id] if self.context['_posts']['tags'][id]
          }
        else
          tags = []
          self.context['_posts']['tags'].each_value { |tag|
            tags << tag
          }
          tags
        end
      end

      def to_posts(sub_context)
        sub_context = sub_context.is_a?(Array) ? sub_context : self.context['_posts']['chronological']

        sub_context.map { |id|
          self.context['_posts']['dictionary'][id] if self.context['_posts']['dictionary'][id]
        }
      end

      def to_pages(sub_context)
        puts "=> call: pages_list with context: #{sub_context}"
        pages = []
        if sub_context.is_a?(Array) 
          sub_context.each do |id|
            if self.context[:pages][id]
              pages << self.context[:pages][id]
            end
          end
        else
          self.context[:pages].each_value {|page| pages << page }
        end
        
        pages.each_with_index do |page, i| 
          next unless page['id'] == self.context[:page]['id']
          active_page = page.dup
          active_page['is_active_page'] = true
          pages[i] = active_page
        end
        
        pages
      end

      def to_categories(sub_context)
        if sub_context.is_a?(Array)
          sub_context.map { |id|
            self.context['_posts']['categories'][id] if self.context['_posts']['categories'][id]
          }
        else
          cats = []
          self.context['_posts']['categories'].each_value { |cat|
            cats << cat
          }
          cats
        end
      end

      def analytics
        return '' if self.context['page']['analytics'].to_s == 'false'
        analytics_config = self.context['site']['config']['analytics']
        return '' unless analytics_config && analytics_config['provider']
        
        if analytics_config['provider'] == "custom"
          code = self.partial("custom_analytics")
        else
          code = self.partial("analytics/#{analytics_config['provider']}")
        end

        return "<h2 style='color:red'>!Analytics Provider partial for '#{analytics_config['provider']}' not found </h2>" if code.nil?

        self.render(code)
      end

      def comments
        return '' if self.context['page']['comments'].to_s == 'false'
        comments_config = self.context['site']['config']['comments']
        return '' unless comments_config && comments_config['provider']
        
        if comments_config['provider'] == "custom"
          code = self.partial("custom_comments")
        else
          code = self.partial("comments/#{comments_config['provider']}")
        end
        
        return "<h2 style='color:red'>!Comments Provider partial for '#{comments_config['provider']}' not found </h2>" if code.nil?

        self.render(code)
      end
    
    end #Helpers
  
  end #Templaters
  
end #Ruhoh