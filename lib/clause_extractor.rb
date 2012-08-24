module ClauseExtractor
  class Clause
    require "conjugations" 

    @tense_regexes = {
      "subjunctive future" => [/\bif\s+(i|you|he|she|it|they|we)\s+were\s+(not\s+)*to\s+(not\s+)*search/i],   #if I were to arise
      "subjunctive present"             => [/if\s+(i|you|he|she|it|they|we)\s+should\s+(not\s+)*search/i],  #if I should arise
      "conditional perfect progressive" => [/would\s+(not\s+)*have\s+(not\s+)*been\s+search/i],               #I would have been searching
      "present perfect progressive"     => [/\bhave\s+(not\s+)*been\s+search/i],                              #I have been searching 
      "conditional progressive"         => [/\b(would|[a-z]{1,4}'d)\s+(not\s+)*be\s+search/i],                #I would be searching (I'd)
      "future progressive"              => [/\b(will|[a-z]{1,4}'ll)\s+(not\s+)*be\s+search/i, /\b[a-z]{1,4}'ll\s+(not\s+)*be\s+search/i], #I will be searching
      "past progressive"                => [/\b(was|were)(n't)*\s+(not\s+)*search/i],                                                       #I was searching 
      "present perfect progressive"     => [/\b([a-z]{1,4}'ve|have|has)(n't)*\s+(not\s+)*((just|already)\s+)*been\s+search/i],              #I have been searching
      "conditional perfect"             => [/\b(would|[a-z]{1,4}'d)\s+(not\s+)*have\s+(not\s+)*search/i],                                 #I would not search
      "future perfect"          => [/\b(will|[a-z]{1,4}'ll)\s+have\s+search/i],                                                     #I'll have arisen
      "conditional simple"      => [/\b(would|[a-z]{1,4}'d)(\s+not)*\s+search/i],                                                   #I would arise
      "will-future"             => [/\b(will|[a-z]{1,4}'ll)(\s+not)*\s+search/i],                                                   #I'll arise
      "going to-future"         => [/\b(am|are|i'm|[a-z]{1,4}'re|[a-z]{1,4}'s)\s+(not\s+)*going\s+to\s+search/i],                     #they are going to cry 
      "present progressive"     => [/\b(am|are|is|i'm|\b[a-z]{1,4}'re|\b[a-z]{1,4}'s)\s+(not\s+)*search/i],                         #I'm rising
      "present perfect"         => [/\b(have|has|it's|he's|she's|[a-z]{1,4}'ve)\s+((i|you|he|she|it|they|we)\s+)*(not\s+)*((just|already)\s+)*search/i], #I have arisen/Have I not arisen
      "past perfect"            => [/\b(had|[a-z]{1,4}'d)\s+(not\s+)*(just\s+)*search/i],                                             #I had arisen
      "subjunctive present"     => [/\bthat\s+(i|you|he|she|they|we)\s+(not\s+)*search/i],                                            #that we arrive
      "subjunctive past"        => [/\bif\s+(i|you|he|she|it|they|we)\s+search/i],                                                    #if I arose   
      "simple past"             => [/\b(i|you|he|she|it|they)\s+search/i],                #you chose
      "simple present"          => [
                                      /\b(I|you|they|we|to)\s+search\b/i,                   #arrive
                                      /\b(he|she|it)\s+searchs\b/i,                         #he arrives
                                      /\bsearchs?\s+(it|them|him|her|me|you|us)\b/i,        #adapts it
                                      /\bsearch\s+(it|them|him|her|me|you|us)\b/i],         #adopt it
      "present progressive"       => [/^search\b/i],                                        #searching
      "present perfect"           => [/^search\b/i],                                        #arisen 
      "simple past"               =>[/^search\b/i]                                          #arose
    }

    def self.scan_phrase(regex, a_i, tense_label)
    #  print "#{@phrase} #{tense_label} .. #{regex}\n"
      if match = @phrase.match(/#{regex}/i) 
        @list[@tense_id["#{tense_label}"].to_s+":" + match.to_s + ":" + @verbs[a_i].to_s]=1 if @format.match(/audioverb/)
        @list << "#{tense_label}:#{match.to_s}"                                    unless @format.match(/audioverb/)
      end
      return @phrase, @list
    end

    def self.get_clauses(phrase, format = String.new, verbs=nil, tiempo=nil, id_tiempo=nil, tense_id=nil, con_id=nil)     
      @format = format 
      @phrase = phrase.downcase
      @list = format.match("audioverb") ? Hash.new : Array.new

      @verbs        ||= get_verbs
      @tiempos      ||= get_tiempos
      @id_tiempo    ||= get_id_tiempos
      @tense_id     ||= get_tenses
      @con_id       ||= get_con_id


      a=Array.new
      a = phrase.split(/\s+/) 
      for i in a.length.downto 0 do
        a[i].gsub!(/[!.?\(\)]/,"") if a[i] #remove any punctuation from the word 
          if @con_id[a[i]] then  #if word matches a conjugation
          @tense_regexes.each do |k,v|
            v.each do |regex| 
             regex = regex.to_s.gsub("search", "#{a[i]}")
             scan_phrase(regex, a[i], k)
            end
          end
        end #end if is conjugation
      end#end of looping through each cap
      @list
    end
  end
end
####For generating conjugations.rb content
#@conjugations = get_conjugations  
# @conjugations.each do |k,v|
# @con = v['con']
# @con_id[@con]   = k  #id
# # print "'#{@con}' => #{k},\n"
# #   #print "'#{@con}' => #{v['verb_id']},\n"
# #   #print "'#{@con}' => #{v['tiempo_id']},\n"
# #   @tiempos[@con]  = v['tiempo_id']  #tiempo_id
# #   @verbs[@con]    = v['verb_id']  #verb_id
# end