class ClauseExtractor
  require "conjugations" 
  require "matchers"
  
  def self.get_clauses(phrase, format = String.new, verbs=nil, tiempo=nil, id_tiempo=nil, tense_id=nil, con_id=nil)     
    @format        = format 
    phrase         = phrase.downcase
    #list           = format.match("audioverb") ? Hash.new : Array.new
    list           = Hash.new
    @verbs        ||= get_verbs
    @tiempos      ||= get_tiempos
    @id_tiempo    ||= get_id_tiempos
    @tense_id     ||= get_tenses
    @con_id       ||= get_con_id
    ranges       = []

    phrase_a = phrase.split(/\s+/) 
    phrase_a.length.times do |i|
      phrase_a[i].gsub!(/[!.?\(\)]/,"") if phrase_a[i] #remove any punctuation from the word 
        if @con_id[phrase_a[i]] then  #if word matches a conjugation
        $tense_regexes.each do |k,v|
          if k.match(/#{@id_tiempo[@tiempos[phrase_a[i]]]}/)
            v.each do |tense, regex_array|
              regex_array.each do |regex|
                regex = regex.to_s.gsub("search", "#{phrase_a[i]}")
                phrase, list, ranges = scan_phrase(phrase, list, regex, phrase_a[i], tense, i, ranges)
              end
            end
          end
        end
      end
    end    
    list.each { |k, v| list.delete(k) unless ranges.include?(v) }
    list.each { |k, v| print "#{k}\n" }    
    list
  end
  
  def self.get_match_start_index(verb, match, index)
    #get start position of last occurence of verb in match
    verb_index_in_match = match.index /#{verb}(?!.*#{verb})/i
    #count spaces between match start and verb_index_in_match and subtract that from index
    lo = index - match[0,verb_index_in_match].split(/\s+/).size  
    hi = lo + match[0,verb_index_in_match].split(/\s+/).size
    return lo, hi
  end
    
   def self.scan_phrase(phrase, list, regex, verb, tense_label, index, ranges)
     if match = phrase.match(/#{regex}/i)
       match = match.to_s
       lo, hi = get_match_start_index(verb, match, index)
       ranges = prioritize_ranges(ranges, lo, hi,match)
       if @format.match(/audioverb/)
         list[@tense_id["#{tense_label}"].to_s+":" + match.to_s + ":" + @verbs[verb].to_s] = (lo..hi) 
       else
         list["#{tense_label}:" + match.to_s + ":" + (lo..hi).to_s] = (lo..hi)
       end
     end
     return phrase, list, ranges
   end
  
  def self.prioritize_ranges(ranges, lo, hi,match)
   range = (lo..hi)

   ranges.size.times.each do |r|
     #replace old range with new one if start is same point and new range is longer
     if ranges[r].begin == lo and ranges[r].count < range.count
       ranges[r] = range
     elsif (range.include?(ranges[r].begin) || range.include?(ranges[r].end)) && range.count > ranges[r].count
       ranges.delete_at(r)
     end
   end
   #add range to ranges if it is not already included in an existing range
   if ranges.each.select{|r| r.include?(lo) || r.include?(hi)}.size == 0
     ranges << range
   end
   ranges
 end
end

# ####For generating conjugations.rb content
# @conjugations = get_conjugations  
#  @conjugations.each do |k,v|
#    @con = v['con']
#    @con_id[@con]   = k  #id
#    #print "'#{@con}' => #{k},\n"
#    #print "'#{@con}' => #{v['verb_id']},\n"
#    #print "'#{@con}' => #{v['tiempo_id']},\n"
#    #@tiempos[@con]  = v['tiempo_id']  #tiempo_id
#    #@verbs[@con]    = v['verb_id']  #verb_id
#  end

