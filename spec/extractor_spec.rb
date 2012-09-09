require 'clause_extractor'

tenses = {
  "present perfect"     => ["have you seen", "you have seen", "you have not seen", "has there ever been"],
  "future progressive"  => ["you will be waiting", "will you be waiting", "You will not be waiting"],
  "present perfect progressive" => ["you have been waiting", "have you been waiting", "you have not been waiting", "I have been feeling"],
  "subjunctive future"  => ["if I were to arise", "if I should arise"],
  "going to-future"     => ["they are going to cry", "they're going to cry", "are going to cry"],
  "present progressive" => ["I am crying", "I'm crying", "crying"],
  "conditional perfect" => ["I would have phoned", "you'd have phoned"],
  "past perfect"        => ["I had never studied", "had you studied", "You had not studied"],
  "subjunctive present" => ["that we arrive"],
  "conditional perfect progressive" => ["I would have been searching", "would not have been searching"],
  "conditional progressive" => ["I would be searching", "would not be searching", "I'd not be searching"],
  "subjunctive past"        => ["if I arose"],
  "conditional simple"      => ["I would arise"],
  "will-future"             => ["I'll arise", "I will arise"],
  "past progressive"        => ["I was searching", "was fighting"],
  "future perfect"          => ["I'll have risen", "I will have battled"],
  "simple past"             => ["you chose"],
  "simple present"          => ["arrive", "he arrives", "adapts it"]
  }

tenses.each do |tense, phrases|
  describe "#{tense}" do
    phrases.each do |p|
      it "#{p}" do
        response = ClauseExtractor.get_clauses("#{p}").flatten.to_s
        response.should match(/#{p}/i)
        response.should match(/#{tense}/i)
      end
    end
  end
end
