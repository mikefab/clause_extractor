class ClauseExtractor
  require "conjugations" 
    
  pronouns        = "(i|you|he|she|it|they|we|there)"
  present_perfect = "(already|ever|for|just|never|since|yet)"
  have_has        = "(have|has|haven't|hasn't)"
  was_were        = "(were|was|wasn't|weren't)"
  had             = "([a-z]{1,4}'d|had)(n't)*"
  have_has        = "(have|has|haven't|hasn't|havent|hasnt|has not|have not)"
  contractions    = "(it'*s|he'*s|she'*s|[a-z]{1,4}'*ve)"
  to_be           = "(am|are|'m|'re|'s|is|[a-z]{1,4}'re)"
  will            = "(will|[a-z]{1,4}'ll)"
  would           = "(would|[a-z]{1,4}'d)"
 
  @tense_regexes = {

    'third'      => {
      "simple present"                => [
                                            /\b(he|she|it)\s+search(s)?\b/i,                              #he arrives
                                            /\bsearch(s)?\s+(it|them|him|her|me|you|us)\b/i               #adapts it
                                         ]
                    },
    'infinitive' => {
        "simple present"              => [/\b((I|you|they|we|to)\s+)*+search\b/i],#to arrive
                                                                    
      
        "subjunctive future"          => [
                                            /\bif\s+#{pronouns}\s+#{was_were}\s+(not\s+)*to\s+(not\s+)*search/i,   #if I were to arise
                                            /\bif\s+#{pronouns}\s+should(n't)*\s+(not\s+)*search/i                #If I should arise
                                         ],
        "subjunctive present"         => [  /\bthat\s+#{pronouns}\s+(not\s+)*search/i],                       #that we arrive

        "conditional simple"          => [  /\b(#{pronouns}\s+)*(would(n't)*|[a-z]{1,4}'d)(\s+not)*\s+search/i],    #I would arise, I wouldn't arise

        "will-future"                 => [  /\b(#{pronouns}\s+)*(will|[a-z]{1,4}'ll)(\s+not)*\s+search/i],    #I'll arise

        "going to-future"             => [  /\b(#{pronouns}\s+)*#{to_be}\s+(not\s+)*going\s+to\s+search/i],   #they are going to cry 
                      }, 
    'gerund' => {
     "conditional perfect progressive" => [ /\b(#{pronouns}\s+)*would\s+(not\s+)*have\s+(not\s+)*been\s+search/i], #I would have been searching
      "present perfect progressive"     => [
                                            /\b(#{have_has}\s+)(#{pronouns}\s+)*(not\s+)*(#{present_perfect}\s+)*been\s+search/i, #have they not been searching
                                            /\b(#{pronouns}\s+)*#{have_has}*\s+(not\s+)*(#{present_perfect}\s+)*been\s+search/i   #I have been searching
                                            ],   
     "past perfect progressive"        => [
                                            /\b(#{pronouns}\s+)*#{had}\s(not\s+)*(#{present_perfect}\s+)*been\s+search/i, #I had been searching, 
                                            /\bhad(n't)*\s+(#{pronouns}\s+)*(not\s+)*(#{present_perfect}\s+)*been\s+search/i, #had he not been searching
                                            
                                          ],   #I had been searching, had he not been searching

      "conditional progressive"         => [/\b(#{pronouns}\s+)*#{would}\s+(not\s+)*be\s+search/i],   #I would be searching (I'd)
      "future progressive"              => [
                                            /\b((#{pronouns})\s+)*#{will}\s+(not\s+)*be\s+search/i,
                                            /\bwill\s+(#{pronouns}\s+)(not\s+)*be\s+search/i,
                                          ],                                                                      #I will be searching
      "past progressive"                => [/\b(#{pronouns}\s+)*#{was_were}*\s+(not\s+)*search/i],            #I was searching                                         

      "present progressive"             => [/\b(#{pronouns}\s*)*(#{to_be}\s+)*(not\s+)*search/i],      #I'm rising
                },
    "past-participle" => {
      "conditional perfect"             => [/\b(#{pronouns}\s+)*#{would}\s+(not\s+)*have\s+(not\s+)*search/i],                                 #I would not search      
      "future perfect"                  => [/\b(#{pronouns}\s+)*#{will}\s+have\s+search/i],            #I'll have arisen      
      "past perfect"                    => [/\b(#{pronouns}\s+)*#{had}\s+(#{pronouns}\s+)*(not\s+)*((#{present_perfect})\s+)*search/i],  #I had arisen
      "present perfect"                 => [
                                            /\b(#{pronouns}\s+)*#{have_has}\s+((#{present_perfect})\s+)*search/,             #They have already seen 
                                            /\b#{have_has}\s+(#{pronouns}\s+)*(not\s+)*(#{present_perfect}\s+)*search/        #Have they already seen
                                          ],
      "subjunctive past"                => [/\bif\s+(i|you|he|she|it|they|we)\s+search/i],                          #if I arose 
      "simple past"                     => [/\b#{pronouns}\s+search/i]                                              #you chose
    },     
    #"present perfect"             => [/^\s*search\b/i],                                        #arisen 
    #"simple past"                 => [/^\s*search\b/i]                                          #arose
  }
  def self.get_match_start_index(verb, match, index)
    #get start position of last occurence of verb in match
    verb_index_in_match = match.index /#{verb}(?!.*#{verb})/i
    #count spaces between match start and verb_index_in_match and subtract that from index
    lo = index - match[0,verb_index_in_match].split(/\s+/).size  
    hi = lo + match[0,verb_index_in_match].split(/\s+/).size
    return lo, hi
  end
  
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
    a=Array.new
    a = phrase.split(/\s+/) 
    a.length.times do |i|
      a[i].gsub!(/[!.?\(\)]/,"") if a[i] #remove any punctuation from the word 
        if @con_id[a[i]] then  #if word matches a conjugation
        @tense_regexes.each do |k,v|
          if k.match(/#{@id_tiempo[@tiempos[a[i]]]}/)
            v.each do |tense, regex_array|
              regex_array.each do |regex|
                regex = regex.to_s.gsub("search", "#{a[i]}")
                phrase, list, ranges = scan_phrase(phrase, list, regex, a[i], tense, i, ranges)
              end
            end
          end
        end
      end #end if is conjugation
    end#end of looping through each cap
    list.each do |k, v| 
     list.delete(k) unless ranges.include?(v)
    end
    list.each do |k,v| 
      print "#{k}\n"
    end
    list
  end
  
   def self.scan_phrase(phrase, list, regex, verb, tense_label, index, ranges)
     if match = phrase.match(/#{regex}/i)
       match = match.to_s
       lo, hi = get_match_start_index(verb, match, index)
       ranges = prioritize_ranges(ranges, lo, hi,match)
       if @format.match(/audioverb/)
         list[@tense_id["#{tense_label}"].to_s+":" + match.to_s + ":" + @verbs[verb].to_s] = (lo..hi) 
       else
         list["#{tense_label}:" + match.to_s + ":" + (lo..hi).to_s] = (lo..hi) unless @format.match(/audioverb/)
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

