#encoding: utf-8
pronouns        = "(i|you|he|she|it|they|we|there)"
present_perfect = "(already|ever|for|just|never|since|yet)"
have_has        = "(have|has|haven't|hasn't)"
was_were        = "(were|was|wasn't|weren't)"
had             = "([a-z]{1,4}'d|had)(n't)*"
have_has        = "(have|has|haven't|hasn't|havent|hasnt|has not|have not)"
contractions    = "(it'*s|he'*s|she'*s|[a-z]{1,4}'*ve)"
should          = "should(n't)*"
to_be           = "(am|are|'m|'re|'s|is|[a-z]{1,4}'re)"
will            = "(will|won't|[a-z]{1,4}'ll)"
would           = "(would(n't)*|[a-z]{1,4}'d)"

$tense_regexes = {

  'third'           => {
    "simple present"                  => [
                                          /\b(he|she|it)\s+search(s)?\b/i,                              #he arrives
                                          /\bsearch(s)?\s+(it|them|him|her|me|you|us)\b/i               #adapts it
                                         ]
                       },
  'infinitive'      => {
      "simple present"                => [/\b((I|you|they|we|to)\s+)*+search\b/i],#to arrive
                                                                  
      "subjunctive future"            => [
                                          /\bif\s+#{pronouns}\s+#{was_were}\s+(not\s+)*to\s+(not\s+)*search/i,   #if I were to arise
                                          /\bif\s+#{pronouns}\s+#{should}\s+(not\s+)*search/i                #If I should arise
                                         ],
      "subjunctive present"           => [  /\bthat\s+#{pronouns}\s+(not\s+)*search/i],                           #that we arrive
      "conditional simple"            => [  /\b(#{pronouns}\s+)*#{would}(\s+not)*\s+search/i],  #I would arise, I wouldn't arise
      "will-future"                   => [  /\b(#{pronouns}\s+)*#{will}(\s+not)*\s+search/i],        #I'll arise
      "going to-future"               => [  /\b(#{pronouns}\s+)*#{to_be}\s+(not\s+)*going\s+to\s+search/i],       #they are going to cry 
                       }, 
  'gerund'          => {
   "conditional perfect progressive"  => [ /\b(#{pronouns}\s+)*#{would}\s+(not\s+)*have\s+(not\s+)*been\s+search/i], #I would have been searching
    "present perfect progressive"     => [
                                          /\b(#{have_has}\s+)(#{pronouns}\s+)*(not\s+)*(#{present_perfect}\s+)*been\s+search/i, #have they not been searching
                                          /\b(#{pronouns}\s+)*#{have_has}*\s+(not\s+)*(#{present_perfect}\s+)*been\s+search/i   #I have been searching
                                         ],   
   "past perfect progressive"         => [
                                          /\b(#{pronouns}\s+)*#{had}\s(not\s+)*(#{present_perfect}\s+)*been\s+search/i, #I had been searching, 
                                          /\bhad(n't)*\s+(#{pronouns}\s+)*(not\s+)*(#{present_perfect}\s+)*been\s+search/i, #had he not been searching                                            
                                         ],
    "conditional progressive"         => [/\b(#{pronouns}\s+)*#{would}\s+(not\s+)*be\s+search/i],   #I would be searching (I'd)
    "future progressive"              => [
                                          /\b((#{pronouns})\s+)*#{will}\s+(not\s+)*be\s+search/i,
                                          /\b#{will}\s+(#{pronouns}\s+)(not\s+)*be\s+search/i,
                                         ],                                                          #I will be searching
    "past progressive"                => [/\b(#{pronouns}\s+)*#{was_were}*\s+(not\s+)*search/i],    #I was searching                                         
    "present progressive"             => [/\b(#{pronouns}\s*)*(#{to_be}\s+)*(not\s+)*search/i],      #I'm rising
                        },
  'past-participle' =>  {
    "conditional perfect"             => [/\b(#{pronouns}\s+)*#{would}\s+(not\s+)*have\s+(not\s+)*search/i],                                 #I would not search      
    "future perfect"                  => [/\b(#{pronouns}\s+)*#{will}\s+have\s+search/i],            #I'll have arisen      
    "past perfect"                    => [
                                            /\b(#{pronouns}\s+)*#{had}\s+(not\s+)*((#{present_perfect})\s+)*search/i,  #I had arisen
                                            /\b#{had}\s+(#{pronouns}\s+)*(not\s+)*((#{present_perfect})\s+)*search/i
                                         ],    
    "present perfect"                 => [
                                          /\b(#{pronouns}\s+)*#{have_has}\s+((#{present_perfect})\s+)*search/,             #They have already seen 
                                          /\b#{have_has}\s+(#{pronouns}\s+)*(not\s+)*(#{present_perfect}\s+)*search/       #Have they already seen
                                         ],
    "subjunctive past"                => [/\bif\s+#{pronouns}\s+search/i],                          #if I arose 
    "simple past"                     => [/\b#{pronouns}\s+search/i]                                #you chose
                        },     
  #"present perfect"             => [/^\s*search\b/i],                                        #arisen 
  #"simple past"                 => [/^\s*search\b/i]                                          #arose
                      }
