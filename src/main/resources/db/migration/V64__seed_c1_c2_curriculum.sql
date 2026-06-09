-- =============================================================================
-- V64 - Seed C1/C2 curriculum from KHUNG_GIAO_TRINH_CEFR.md
-- =============================================================================
-- Scope:
--   * C1: 10 units, 52 lessons, reusing C1 flashcard decks from V38.
--   * C2: 10 units, 52 lessons, greenfield curriculum skeleton with auto-graded
--     practice/quiz placeholders for grammar, vocabulary, reading and listening.
--   * Each normal lesson has 3 practice + 5 quiz activities.
--   * Each unit review has 10 quiz activities and sets review_lesson_id.
--
-- This keeps the same schema and naming style as A1/A2/B1/B2 seeds while avoiding
-- a huge hand-written file. Detailed passages/audio/scripts can be expanded later
-- without changing unit/lesson IDs.
-- =============================================================================

UPDATE learning_units SET review_lesson_id = NULL WHERE level_code IN ('C1', 'C2');

DELETE FROM learning_lesson_activities
 WHERE lesson_id IN (
   SELECT id
     FROM learning_lessons
    WHERE level_code IN ('C1', 'C2')
      AND (id LIKE 'c1-u%' OR id LIKE 'c2-u%' OR unit_id IN (SELECT id FROM learning_units WHERE level_code IN ('C1', 'C2')))
 );

DELETE FROM learning_path_activities
 WHERE lesson_id IN (
   SELECT id
     FROM learning_lessons
    WHERE level_code IN ('C1', 'C2')
      AND (id LIKE 'c1-u%' OR id LIKE 'c2-u%' OR unit_id IN (SELECT id FROM learning_units WHERE level_code IN ('C1', 'C2')))
 );

DELETE FROM learning_lessons
 WHERE level_code IN ('C1', 'C2')
   AND (id LIKE 'c1-u%' OR id LIKE 'c2-u%' OR unit_id IN (SELECT id FROM learning_units WHERE level_code IN ('C1', 'C2')));

DELETE FROM learning_units WHERE level_code IN ('C1', 'C2');

DO $$
DECLARE
  curriculum jsonb := '[
    {
      "level":"C1",
      "pass":75,
      "units":[
        {"title":"Abstract Ideas & Complex Discussions","subtitle":"Y tuong truu tuong va thao luan phuc tap","theme":"abstract-discussion","skills":["grammar","vocabulary","reading"],"lessons":[
          {"title":"From Verbs to Nouns","subtitle":"Nominalisation for formal writing","type":"normal","skill":"writing","focus":"nominalisation","canDo":"write formal academic sentences by turning verbs and clauses into noun phrases"},
          {"title":"Hedging & Distancing","subtitle":"Arguably, to some extent, broadly speaking","type":"normal","skill":"speaking","focus":"hedging and distancing","canDo":"express careful opinions without sounding too absolute"},
          {"title":"Society & Culture Words","subtitle":"C1 society, culture and education vocabulary","type":"normal","skill":"reading","focus":"abstract society vocabulary","canDo":"use C1 words for social issues, culture and education"},
          {"title":"Reading: The Idea of Progress","subtitle":"Authentic-style abstract reading","type":"normal","skill":"reading","focus":"summarising and inference","canDo":"summarise and comment on a complex abstract text"},
          {"title":"Unit 1 Review","subtitle":"Nominalisation, hedging and society vocabulary","type":"unit_review","skill":"reading","focus":"Unit 1 synthesis","canDo":"consolidate abstract discussion language"}
        ]},
        {"title":"Emphasis & Inversion","subtitle":"Nhan manh va dao ngu","theme":"rhetoric","skills":["grammar","vocabulary","listening"],"lessons":[
          {"title":"Negative Adverbial Inversion","subtitle":"Never, rarely, no sooner, not only","type":"normal","skill":"writing","focus":"negative adverbial inversion","canDo":"use formal inversion to emphasise an argument"},
          {"title":"Restrictive Inversion","subtitle":"Only after, not until, under no circumstances","type":"normal","skill":"writing","focus":"restrictive inversion","canDo":"structure persuasive writing with restrictive fronting"},
          {"title":"Persuasion Vocabulary","subtitle":"C1 politics, law, media and rhetoric words","type":"normal","skill":"reading","focus":"persuasion vocabulary","canDo":"choose words that signal stance and persuasion"},
          {"title":"Listening: A Persuasive Talk","subtitle":"Listen for stance and rhetorical intention","type":"normal","skill":"listening","focus":"persuasive listening","canDo":"identify main argument, stance and intended effect"},
          {"title":"Unit 2 Review","subtitle":"Inversion and persuasion language","type":"unit_review","skill":"reading","focus":"Unit 2 synthesis","canDo":"consolidate rhetorical emphasis"}
        ]},
        {"title":"Hypotheses & Counterfactuals","subtitle":"Gia thuyet va tinh huong phan thuc","theme":"science-speculation","skills":["grammar","vocabulary","reading"],"lessons":[
          {"title":"Conditional Inversion","subtitle":"Were she to, had I known, should you wish","type":"normal","skill":"writing","focus":"conditional inversion","canDo":"express formal hypothetical conditions"},
          {"title":"But For & Reduced Conditionals","subtitle":"But for, if it were not for, otherwise","type":"normal","skill":"writing","focus":"reduced conditionals","canDo":"state compact counterfactual conditions"},
          {"title":"As If / As Though","subtitle":"Past and past perfect counterfactual meaning","type":"normal","skill":"speaking","focus":"as if and as though","canDo":"describe unreal impressions and past counterfactuals"},
          {"title":"Science & Research Words","subtitle":"C1 science, research and environment words","type":"normal","skill":"reading","focus":"science vocabulary","canDo":"discuss hypotheses, evidence and correlation"},
          {"title":"Reading: What If","subtitle":"Counterfactual science scenario","type":"normal","skill":"reading","focus":"hypothetical inference","canDo":"infer consequences from a speculative text"},
          {"title":"Unit 3 Review","subtitle":"Counterfactuals and science language","type":"unit_review","skill":"reading","focus":"Unit 3 synthesis","canDo":"consolidate hypothetical language"}
        ]},
        {"title":"Cleft Sentences & Focus","subtitle":"Cau che va tao tieu diem","theme":"business-focus","skills":["grammar","vocabulary","reading"],"lessons":[
          {"title":"It-cleft","subtitle":"It is X that, it was not until that","type":"normal","skill":"writing","focus":"it-cleft sentences","canDo":"highlight key information accurately"},
          {"title":"Wh-cleft","subtitle":"What I need is, the thing that matters is","type":"normal","skill":"speaking","focus":"wh-cleft sentences","canDo":"organise speech around a clear focus"},
          {"title":"Business & Economy Words","subtitle":"C1 business, economy and career words","type":"normal","skill":"reading","focus":"business vocabulary","canDo":"discuss stakeholders, revenue and strategy"},
          {"title":"Reading: A Negotiation Case","subtitle":"Business case reading","type":"normal","skill":"reading","focus":"business inference","canDo":"analyse arguments and trade-offs in business writing"},
          {"title":"Unit 4 Review","subtitle":"Clefts and business vocabulary","type":"unit_review","skill":"reading","focus":"Unit 4 synthesis","canDo":"consolidate focus structures"}
        ]},
        {"title":"Participle & Reduced Clauses","subtitle":"Menh de phan tu va rut gon","theme":"cohesive-narrative","skills":["grammar","vocabulary","listening"],"lessons":[
          {"title":"Participle Clauses","subtitle":"Walking into the room, having finished, shocked by","type":"normal","skill":"writing","focus":"participle clauses","canDo":"write cohesive sentences with reduced clauses"},
          {"title":"Given & Concessive Reduced Clauses","subtitle":"Given that, much as, try as I might","type":"normal","skill":"writing","focus":"concessive reduced clauses","canDo":"connect concession and contrast concisely"},
          {"title":"Technology & Travel Words","subtitle":"C1 technology, mobility and daily life words","type":"normal","skill":"reading","focus":"technology and travel vocabulary","canDo":"describe innovation, infrastructure and movement"},
          {"title":"Listening: A Travel Anecdote","subtitle":"Sequence and attitude in a story","type":"normal","skill":"listening","focus":"narrative listening","canDo":"follow event sequence and emotional stance"},
          {"title":"Unit 5 Review","subtitle":"Reduced clauses and technology vocabulary","type":"unit_review","skill":"reading","focus":"Unit 5 synthesis","canDo":"consolidate cohesive narrative language"}
        ]},
        {"title":"Reporting & Distancing the Source","subtitle":"Tuong thuat va tao khoang cach nguon","theme":"news","skills":["grammar","vocabulary","reading"],"lessons":[
          {"title":"Passive Reporting","subtitle":"It is thought that, is believed to have","type":"normal","skill":"writing","focus":"passive reporting","canDo":"report claims objectively and impersonally"},
          {"title":"Reporting Verbs in Depth","subtitle":"Allege, claim, deny, urge, concede, acknowledge","type":"normal","skill":"writing","focus":"reporting verbs","canDo":"choose reporting verbs with precise stance"},
          {"title":"News & Society Words","subtitle":"C1 current affairs and politics vocabulary","type":"normal","skill":"reading","focus":"news vocabulary","canDo":"understand and use public affairs vocabulary"},
          {"title":"Reading: A News Report","subtitle":"Fact, opinion and source stance","type":"normal","skill":"reading","focus":"news source evaluation","canDo":"distinguish fact, attribution and opinion"},
          {"title":"Unit 6 Review","subtitle":"Reporting and news vocabulary","type":"unit_review","skill":"reading","focus":"Unit 6 synthesis","canDo":"consolidate source distancing"}
        ]},
        {"title":"Modal Nuance & Criticism","subtitle":"Sac thai khuyet thieu va phe phan","theme":"reflection","skills":["grammar","vocabulary","listening"],"lessons":[
          {"title":"Criticism & Regret in the Past","subtitle":"Should have, ought to have, need not have","type":"normal","skill":"speaking","focus":"past modal criticism","canDo":"criticise past actions tactfully"},
          {"title":"Speculating about the Past","subtitle":"Must have, may well have, cannot have","type":"normal","skill":"speaking","focus":"past deduction softening","canDo":"make nuanced deductions about past events"},
          {"title":"Health & Emotion Words","subtitle":"C1 health, body, emotion and personality words","type":"normal","skill":"reading","focus":"health and emotion vocabulary","canDo":"describe wellbeing and emotion precisely"},
          {"title":"Listening: A Reflective Interview","subtitle":"Regret and attitude in spoken reflection","type":"normal","skill":"listening","focus":"reflective listening","canDo":"hear regret, criticism and emotional nuance"},
          {"title":"Unit 7 Review","subtitle":"Modal nuance and reflection vocabulary","type":"unit_review","skill":"reading","focus":"Unit 7 synthesis","canDo":"consolidate modal nuance"}
        ]},
        {"title":"The Subjunctive & Formal Register","subtitle":"Thuc gia dinh va van phong trang trong","theme":"formal-academic","skills":["grammar","vocabulary","reading"],"lessons":[
          {"title":"The Subjunctive","subtitle":"I insist that he leave, it is vital that","type":"normal","skill":"writing","focus":"mandative subjunctive","canDo":"make formal recommendations and requirements"},
          {"title":"Formal & Polite Structures","subtitle":"Would you be so kind as to, I would be grateful if","type":"normal","skill":"speaking","focus":"formal politeness","canDo":"shift requests into formal register"},
          {"title":"Academic & Career Words","subtitle":"C1 academic, career and study vocabulary","type":"normal","skill":"reading","focus":"academic vocabulary","canDo":"use academic and professional terms accurately"},
          {"title":"Reading: An Academic Abstract","subtitle":"Argument and register in an abstract","type":"normal","skill":"reading","focus":"academic reading","canDo":"identify thesis, scope and academic register"},
          {"title":"Unit 8 Review","subtitle":"Subjunctive and formal register","type":"unit_review","skill":"reading","focus":"Unit 8 synthesis","canDo":"consolidate formal academic language"}
        ]},
        {"title":"Idiomatic & Nuanced English","subtitle":"Thanh ngu va sac thai tinh te","theme":"idiom-nuance","skills":["grammar","vocabulary","reading"],"lessons":[
          {"title":"Compound Adjectives","subtitle":"Well-established, thought-provoking, time-consuming","type":"normal","skill":"writing","focus":"compound adjectives","canDo":"describe ideas concisely with compound modifiers"},
          {"title":"Adjective Position & Intensity","subtitle":"Utter, sheer, mere, involved, concerned","type":"normal","skill":"writing","focus":"adjective position and intensity","canDo":"control adjective position and emphasis"},
          {"title":"Idioms & Collocations","subtitle":"C1 idioms, connotation and collocation","type":"normal","skill":"reading","focus":"idiomatic vocabulary","canDo":"use idiomatic phrases with appropriate register"},
          {"title":"Reading: Nuanced Reviews","subtitle":"Tone and evaluation in reviews","type":"normal","skill":"reading","focus":"tone inference","canDo":"infer praise, criticism and implication"},
          {"title":"Unit 9 Review","subtitle":"Nuanced adjectives and idiom","type":"unit_review","skill":"reading","focus":"Unit 9 synthesis","canDo":"consolidate nuanced expression"}
        ]},
        {"title":"Synthesis, Cohesion & Mastery","subtitle":"Tong hop, lien ket va thanh thao","theme":"c1-consolidation","skills":["grammar","vocabulary","reading","listening"],"lessons":[
          {"title":"Advanced Linking","subtitle":"Whereby, insofar as, nevertheless, moreover","type":"normal","skill":"writing","focus":"advanced cohesive devices","canDo":"link long arguments clearly"},
          {"title":"Concession & Contrast","subtitle":"Albeit, much as, nevertheless, despite the fact that","type":"normal","skill":"writing","focus":"concession and contrast","canDo":"balance opposing ideas in formal prose"},
          {"title":"Synthesis Vocabulary","subtitle":"Argument, evaluation and academic signposting","type":"normal","skill":"reading","focus":"synthesis vocabulary","canDo":"signal evidence, implication and evaluation"},
          {"title":"Reading: Two Contrasting Arguments","subtitle":"Compare and evaluate sources","type":"normal","skill":"reading","focus":"source synthesis","canDo":"compare claims across two complex sources"},
          {"title":"Listening: Academic Discussion","subtitle":"Listen for agreement, challenge and synthesis","type":"normal","skill":"listening","focus":"academic discussion listening","canDo":"follow a complex multi-speaker discussion"},
          {"title":"Unit 10 Review","subtitle":"Final C1 consolidation","type":"unit_review","skill":"reading","focus":"C1 final synthesis","canDo":"prepare for the C1 checkpoint"}
        ]}
      ]
    },
    {
      "level":"C2",
      "pass":80,
      "units":[
        {"title":"Precision & Nuance","subtitle":"Do chinh xac va sac thai","theme":"precision","skills":["grammar","vocabulary","reading"],"lessons":[
          {"title":"The Modification System","subtitle":"Premodification, postmodification and degree","type":"normal","skill":"writing","focus":"advanced modification","canDo":"fine tune meaning with precise modifiers"},
          {"title":"Hedging & Downtoning","subtitle":"Ostensibly, if anything, more or less","type":"normal","skill":"writing","focus":"C2 hedging and downtoning","canDo":"calibrate certainty and intensity"},
          {"title":"Shades of Meaning Vocabulary","subtitle":"Gradation, stance adverbs and connotation","type":"normal","skill":"reading","focus":"shades of meaning vocabulary","canDo":"choose words by nuance, stance and intensity"},
          {"title":"Reading: Op-ed Nuance","subtitle":"Infer stance through modification","type":"normal","skill":"reading","focus":"op-ed nuance","canDo":"infer author attitude from subtle wording"},
          {"title":"Unit 1 Review","subtitle":"Modification, hedging and nuanced vocabulary","type":"unit_review","skill":"reading","focus":"Unit 1 synthesis","canDo":"consolidate precision and nuance"}
        ]},
        {"title":"Ellipsis & Substitution","subtitle":"Luoc bo va thay the","theme":"cohesion","skills":["grammar","vocabulary","listening"],"lessons":[
          {"title":"Textual & Situational Ellipsis","subtitle":"Recover omitted meaning in natural discourse","type":"normal","skill":"listening","focus":"ellipsis","canDo":"understand and use natural ellipsis"},
          {"title":"Substitution: One, Do, So, Such","subtitle":"Avoid repetition with substitution","type":"normal","skill":"writing","focus":"substitution devices","canDo":"keep discourse cohesive without repetition"},
          {"title":"Cohesion Markers Vocabulary","subtitle":"Former, latter, likewise, accordingly","type":"normal","skill":"reading","focus":"cohesion vocabulary","canDo":"track references across long discourse"},
          {"title":"Listening: Elided Conversation","subtitle":"Natural speech with reduced forms","type":"normal","skill":"listening","focus":"elided conversation","canDo":"understand fast conversation with omissions"},
          {"title":"Unit 2 Review","subtitle":"Ellipsis, substitution and cohesion markers","type":"unit_review","skill":"reading","focus":"Unit 2 synthesis","canDo":"consolidate discourse economy"}
        ]},
        {"title":"Emphasis & Information Structuring","subtitle":"Nhan manh va cau truc thong tin","theme":"information-structure","skills":["grammar","vocabulary","reading"],"lessons":[
          {"title":"Cleft Sentences Mastery","subtitle":"It, what, all, the reason and the thing clefts","type":"normal","skill":"writing","focus":"cleft mastery","canDo":"foreground information strategically"},
          {"title":"Fronting & Marked Theme","subtitle":"Marked themes for rhetorical control","type":"normal","skill":"writing","focus":"fronting","canDo":"move information to control emphasis"},
          {"title":"Inversion Mastery","subtitle":"Negative, restrictive and conditional inversion","type":"normal","skill":"writing","focus":"inversion mastery","canDo":"use inversion flexibly across registers"},
          {"title":"Emphasis & Focusing Vocabulary","subtitle":"Precisely, above all, not least, in particular","type":"normal","skill":"reading","focus":"focusing vocabulary","canDo":"signal focus and emphasis precisely"},
          {"title":"Reading: Rhetorical Prose","subtitle":"Cleft, fronting and inversion as rhetoric","type":"normal","skill":"reading","focus":"rhetorical reading","canDo":"identify the effect of information structure"},
          {"title":"Unit 3 Review","subtitle":"Cleft, fronting and inversion","type":"unit_review","skill":"reading","focus":"Unit 3 synthesis","canDo":"consolidate strategic emphasis"}
        ]},
        {"title":"Register & Style","subtitle":"Van phong va ngu vuc","theme":"register","skills":["grammar","vocabulary","reading"],"lessons":[
          {"title":"Nominalisation & Complex Nominal Groups","subtitle":"Dense formal noun phrases","type":"normal","skill":"writing","focus":"complex nominal groups","canDo":"turn clauses into dense formal noun phrases"},
          {"title":"Strategic Passive & Impersonal Style","subtitle":"Objectivity and hidden agency","type":"normal","skill":"writing","focus":"strategic passive","canDo":"control objectivity and agency"},
          {"title":"Formal vs Informal Vocabulary","subtitle":"Register pairs and discourse markers","type":"normal","skill":"reading","focus":"register vocabulary","canDo":"switch between formal, neutral and informal language"},
          {"title":"Reading: Genre & Register","subtitle":"Compare academic, journalistic and informal style","type":"normal","skill":"reading","focus":"genre and register","canDo":"identify genre conventions and register choices"},
          {"title":"Unit 4 Review","subtitle":"Nominalisation, passive and register","type":"unit_review","skill":"reading","focus":"Unit 4 synthesis","canDo":"consolidate register control"}
        ]},
        {"title":"The Subjunctive & Hypothetical Distance","subtitle":"Thuc gia dinh va khoang cach gia thuyet","theme":"hypothetical-distance","skills":["grammar","vocabulary"],"lessons":[
          {"title":"Mandative Subjunctive","subtitle":"It is essential that it be done","type":"normal","skill":"writing","focus":"mandative subjunctive mastery","canDo":"use formal recommendations with subjunctive forms"},
          {"title":"Conditional Inversion","subtitle":"Were she to, had I known, should you wish","type":"normal","skill":"writing","focus":"C2 conditional inversion","canDo":"express formal hypothetical distance"},
          {"title":"Mixed & Multi-layer Conditionals","subtitle":"Layered counterfactual conditions","type":"normal","skill":"writing","focus":"multi-layer conditionals","canDo":"combine time frames in complex counterfactuals"},
          {"title":"Hypothesising Vocabulary","subtitle":"Supposing, conceivably, in the event that","type":"normal","skill":"reading","focus":"hypothesising vocabulary","canDo":"signal assumptions, conditions and speculation"},
          {"title":"Unit 5 Review","subtitle":"Subjunctive and hypothetical distance","type":"unit_review","skill":"reading","focus":"Unit 5 synthesis","canDo":"consolidate advanced hypotheticals"}
        ]},
        {"title":"Idiomatic English","subtitle":"Tieng Anh thanh ngu","theme":"idiom","skills":["grammar","vocabulary","listening"],"lessons":[
          {"title":"Phrasal Verb Splitting & Particles","subtitle":"Separable and inseparable patterns","type":"normal","skill":"writing","focus":"phrasal verb splitting","canDo":"place particles and objects naturally"},
          {"title":"Idiom Flexibility & Fixedness","subtitle":"Fixed and flexible idiomatic patterns","type":"normal","skill":"speaking","focus":"idiom flexibility","canDo":"use idioms without breaking their fixed meaning"},
          {"title":"C2 Idioms & Connotation","subtitle":"High-level idioms and implied attitude","type":"normal","skill":"reading","focus":"C2 idioms","canDo":"understand idioms with connotation and register"},
          {"title":"Metaphor & Strong Collocation","subtitle":"Conceptual metaphors, binomials and fixed collocations","type":"normal","skill":"reading","focus":"metaphor and strong collocation","canDo":"use strong collocations and figurative language"},
          {"title":"Listening: Idiomatic Speech","subtitle":"Podcast-style idiomatic speech","type":"normal","skill":"listening","focus":"idiomatic listening","canDo":"understand natural speech rich in idiom"},
          {"title":"Unit 6 Review","subtitle":"Phrasal verbs, idioms and collocation","type":"unit_review","skill":"reading","focus":"Unit 6 synthesis","canDo":"consolidate idiomatic English"}
        ]},
        {"title":"Reporting & Distancing","subtitle":"Tuong thuat va tao khoang cach","theme":"reporting","skills":["grammar","vocabulary","reading"],"lessons":[
          {"title":"Advanced Passive Reporting","subtitle":"It is widely held that, X is reputed to","type":"normal","skill":"writing","focus":"advanced passive reporting","canDo":"attribute claims with distance and precision"},
          {"title":"Reporting Verbs & Stance","subtitle":"Concede, assert, refute, posit, acknowledge","type":"normal","skill":"writing","focus":"reporting stance","canDo":"select reporting verbs by stance"},
          {"title":"Hedging & Distancing Vocabulary","subtitle":"Apparently, allegedly, the evidence suggests","type":"normal","skill":"reading","focus":"distancing vocabulary","canDo":"signal doubt, evidence and source distance"},
          {"title":"Reading: Academic Argument","subtitle":"Attribution and hedging in academic prose","type":"normal","skill":"reading","focus":"academic attribution","canDo":"separate writer stance from cited source stance"},
          {"title":"Unit 7 Review","subtitle":"Reporting, stance and distancing","type":"unit_review","skill":"reading","focus":"Unit 7 synthesis","canDo":"consolidate attribution control"}
        ]},
        {"title":"Cohesion & Complex Discourse","subtitle":"Lien ket va dien ngon phuc hop","theme":"complex-discourse","skills":["grammar","vocabulary","reading"],"lessons":[
          {"title":"Advanced Participle Clauses","subtitle":"Being, having, given and appended clauses","type":"normal","skill":"writing","focus":"advanced participle clauses","canDo":"combine ideas into dense cohesive sentences"},
          {"title":"Concessive & Universal Clauses","subtitle":"Whatever, however, much as, albeit","type":"normal","skill":"writing","focus":"advanced concessive clauses","canDo":"express concession across complex arguments"},
          {"title":"Discourse Markers Vocabulary","subtitle":"Conversely, thereby, notwithstanding, insofar as","type":"normal","skill":"reading","focus":"discourse marker vocabulary","canDo":"guide readers through complex reasoning"},
          {"title":"Reading: The Long Argument","subtitle":"Gap text and paragraph ordering","type":"normal","skill":"reading","focus":"long argument cohesion","canDo":"track cohesion in long complex texts"},
          {"title":"Unit 8 Review","subtitle":"Participle clauses and discourse markers","type":"unit_review","skill":"reading","focus":"Unit 8 synthesis","canDo":"consolidate complex discourse"}
        ]},
        {"title":"Reading Between the Lines","subtitle":"Doc giua cac dong","theme":"implication","skills":["grammar","vocabulary","reading"],"lessons":[
          {"title":"Irony, Understatement & Litotes","subtitle":"Not bad at all and other implied meanings","type":"normal","skill":"reading","focus":"irony and litotes","canDo":"recognise irony, understatement and implied praise or criticism"},
          {"title":"Implicature & Implied Meaning","subtitle":"Meaning beyond the literal words","type":"normal","skill":"listening","focus":"implicature","canDo":"infer unstated intentions and implications"},
          {"title":"Connotation & Tone Vocabulary","subtitle":"Tone-signalling lexis and figurative vocabulary","type":"normal","skill":"reading","focus":"tone vocabulary","canDo":"choose synonyms by connotation and tone"},
          {"title":"Reading: Literary & Satirical Text","subtitle":"Tone, irony and allusion","type":"normal","skill":"reading","focus":"literary and satirical inference","canDo":"infer attitude in literary or satirical prose"},
          {"title":"Unit 9 Review","subtitle":"Irony, implicature and tone","type":"unit_review","skill":"reading","focus":"Unit 9 synthesis","canDo":"consolidate implied meaning"}
        ]},
        {"title":"Mastering Debate","subtitle":"Lam chu tranh luan hoc thuat va chuyen nghiep","theme":"debate","skills":["grammar","vocabulary","reading","listening"],"lessons":[
          {"title":"Argumentation Structures","subtitle":"Premise, claim, evidence, rebuttal","type":"normal","skill":"writing","focus":"argumentation structures","canDo":"build layered arguments and rebuttals"},
          {"title":"Synthesis & Evaluation","subtitle":"Evaluate two contrasting sources","type":"normal","skill":"reading","focus":"source synthesis and evaluation","canDo":"synthesise and evaluate competing arguments"},
          {"title":"Argumentation & Academic Vocabulary","subtitle":"Premise, fallacy, corroborate, untenable, salient","type":"normal","skill":"reading","focus":"argumentation vocabulary","canDo":"use advanced vocabulary for debate and evaluation"},
          {"title":"Listening: Academic Debate","subtitle":"Track opposing arguments in speech","type":"normal","skill":"listening","focus":"academic debate listening","canDo":"follow and evaluate opposing spoken arguments"},
          {"title":"Unit 10 Review","subtitle":"Final C2 mastery review","type":"unit_review","skill":"reading","focus":"C2 final synthesis","canDo":"complete the C2 mastery path"}
        ]}
      ]
    }
  ]'::jsonb;
  level_doc jsonb;
  unit_doc jsonb;
  lesson_doc jsonb;
  level_code text;
  unit_no int;
  lesson_no int;
  unit_id text;
  lesson_id text;
  review_id text;
  act_id text;
  phase_order int;
  quiz_count int;
  practice_count int;
  question_text text;
BEGIN
  FOR level_doc IN SELECT value FROM jsonb_array_elements(curriculum)
  LOOP
    level_code := level_doc->>'level';
    unit_no := 0;

    FOR unit_doc IN SELECT value FROM jsonb_array_elements(level_doc->'units')
    LOOP
      unit_no := unit_no + 1;
      unit_id := lower(level_code) || '-u' || lpad(unit_no::text, 2, '0');

      INSERT INTO learning_units (
        id, level_code, title, subtitle, theme, skill_coverage, display_order, required_review_score
      ) VALUES (
        unit_id,
        level_code,
        unit_doc->>'title',
        unit_doc->>'subtitle',
        unit_doc->>'theme',
        unit_doc->'skills',
        unit_no,
        (level_doc->>'pass')::smallint
      );

      lesson_no := 0;
      FOR lesson_doc IN SELECT value FROM jsonb_array_elements(unit_doc->'lessons')
      LOOP
        lesson_no := lesson_no + 1;
        lesson_id := unit_id || '-l' || lesson_no;

        INSERT INTO learning_lessons (
          id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle,
          duration_minutes, xp_reward, required_score_to_pass, content, theory_content
        ) VALUES (
          lesson_id,
          level_code,
          lesson_doc->>'skill',
          unit_id,
          lesson_doc->>'type',
          lesson_no,
          lesson_doc->>'title',
          lesson_doc->>'subtitle',
          CASE WHEN lesson_doc->>'type' = 'unit_review' THEN 18 ELSE 14 END,
          CASE WHEN lesson_doc->>'type' = 'unit_review' THEN 40 ELSE 28 END,
          CASE WHEN lesson_doc->>'type' = 'unit_review' THEN (level_doc->>'pass')::smallint ELSE 70 END,
          jsonb_build_object(
            'source', 'KHUNG_GIAO_TRINH_CEFR.md',
            'contentStatus', CASE WHEN level_code = 'C1' THEN 'needs grammar/reading/listening expansion; C1 vocabulary decks available' ELSE 'greenfield C2 content seed; requires full source expansion' END
          ),
          jsonb_build_object(
            'warmup', 'Before starting, think about how this focus appears in authentic C1/C2 English: ' || (lesson_doc->>'focus') || '.',
            'objectives', jsonb_build_array(lesson_doc->>'canDo', 'Recognise the form in context', 'Answer auto-graded practice and quiz items'),
            'grammarHtml', '<b>Focus:</b> ' || (lesson_doc->>'focus') || '. This lesson follows KHUNG_GIAO_TRINH_CEFR.md and is marked for offline expansion with full examples, passages or scripts.',
            'vocabBlock', jsonb_build_array(
              jsonb_build_object('word', lesson_doc->>'focus', 'ipa', '', 'meaningVi', lesson_doc->>'subtitle', 'example', 'Use this focus in a precise academic or professional sentence.')
            ),
            'examples', jsonb_build_array(
              jsonb_build_object('en', 'This item practises ' || (lesson_doc->>'focus') || ' in context.', 'vi', 'Muc nay luyen ' || (lesson_doc->>'focus') || ' trong ngu canh.'),
              jsonb_build_object('en', 'Learners should notice both meaning and register.', 'vi', 'Nguoi hoc can chu y ca nghia va ngu vuc.')
            ),
            'commonMistakes', jsonb_build_array(
              'Using advanced forms without a clear communicative purpose.',
              'Ignoring register, stance or implied meaning.'
            ),
            'tips', jsonb_build_array(
              'At C levels, accuracy includes nuance, register and cohesion.',
              'Prefer auto-graded quiz items here; longer writing/speaking tasks can be added as non-mastery practice.'
            )
          )
        );

        IF lesson_doc->>'type' = 'unit_review' THEN
          review_id := lesson_id;
          quiz_count := 10;
          FOR phase_order IN 1..quiz_count LOOP
            act_id := lesson_id || '-q' || phase_order;
            question_text := 'Review ' || unit_no || '.' || phase_order || ': choose the best answer for ' || (lesson_doc->>'focus') || '.';
            INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload)
            VALUES (
              act_id,
              lesson_id,
              CASE
                WHEN phase_order IN (3, 7) THEN 'vocabulary_match'
                WHEN phase_order IN (4, 8) THEN 'grammar_fill_blank'
                WHEN phase_order IN (5, 9) THEN 'sentence_ordering'
                ELSE 'multiple_choice'
              END,
              phase_order,
              'quiz',
              CASE WHEN phase_order <= 3 THEN 'easy' WHEN phase_order <= 7 THEN 'medium' ELSE 'hard' END,
              true,
              CASE
                WHEN phase_order IN (3, 7) THEN jsonb_build_object(
                  'question', 'Match the C-level term with its Vietnamese meaning.',
                  'pairs', jsonb_build_array(
                    jsonb_build_object('left', lesson_doc->>'focus', 'right', lesson_doc->>'subtitle'),
                    jsonb_build_object('left', 'register', 'right', 'ngu vuc'),
                    jsonb_build_object('left', 'stance', 'right', 'lap truong')
                  ),
                  'explanationVi', 'On tap tu vung va sac thai cua unit.'
                )
                WHEN phase_order IN (4, 8) THEN jsonb_build_object(
                  'question', 'Fill the blank with a suitable C-level expression: The writer uses ___ to control nuance.',
                  'acceptedAnswers', jsonb_build_array(lesson_doc->>'focus'),
                  'explanationVi', 'Chap nhan trong seed toi thieu; can mo rong dap an khi soan chi tiet.'
                )
                WHEN phase_order IN (5, 9) THEN jsonb_build_object(
                  'question', 'Order the sentence.',
                  'tokens', jsonb_build_array('Nuance','depends','on','register','and','context'),
                  'correctOrder', jsonb_build_array(0,1,2,3,4,5),
                  'explanationVi', 'Nuance depends on register and context.'
                )
                ELSE jsonb_build_object(
                  'question', question_text,
                  'options', jsonb_build_array(
                    jsonb_build_object('id','a','text','A precise and context-aware option'),
                    jsonb_build_object('id','b','text','A vague or overly simple option'),
                    jsonb_build_object('id','c','text','An option with the wrong register')
                  ),
                  'correctOptionId','a',
                  'explanationVi','C1/C2 yeu cau dung ngu canh, ngu vuc va sac thai.'
                )
              END
            );
          END LOOP;
        ELSE
          practice_count := 3;
          FOR phase_order IN 1..practice_count LOOP
            act_id := lesson_id || '-p' || phase_order;
            INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload)
            VALUES (
              act_id,
              lesson_id,
              CASE WHEN phase_order = 1 THEN 'multiple_choice' WHEN phase_order = 2 THEN 'grammar_fill_blank' ELSE 'vocabulary_match' END,
              phase_order,
              'practice',
              CASE WHEN phase_order = 1 THEN 'easy' WHEN phase_order = 2 THEN 'medium' ELSE 'medium' END,
              false,
              CASE
                WHEN phase_order = 1 THEN jsonb_build_object(
                  'question', 'Which option best fits the focus: ' || (lesson_doc->>'focus') || '?',
                  'options', jsonb_build_array(
                    jsonb_build_object('id','a','text','Use it to express precise meaning in context'),
                    jsonb_build_object('id','b','text','Use it only as decoration'),
                    jsonb_build_object('id','c','text','Avoid considering register')
                  ),
                  'correctOptionId','a',
                  'explanationVi','C-level language phai phuc vu y nghia va ngu canh.'
                )
                WHEN phase_order = 2 THEN jsonb_build_object(
                  'question', 'Complete the note: This lesson focuses on ___.',
                  'acceptedAnswers', jsonb_build_array(lesson_doc->>'focus'),
                  'explanationVi','Day la bai tap seed toi thieu de kiem tra nhan dien focus.'
                )
                ELSE jsonb_build_object(
                  'question', 'Match each term with its function.',
                  'pairs', jsonb_build_array(
                    jsonb_build_object('left', lesson_doc->>'focus', 'right', lesson_doc->>'canDo'),
                    jsonb_build_object('left', 'register', 'right', 'style level'),
                    jsonb_build_object('left', 'cohesion', 'right', 'linking ideas')
                  ),
                  'explanationVi','Ghep khai niem voi chuc nang giao tiep.'
                )
              END
            );
          END LOOP;

          FOR phase_order IN 1..5 LOOP
            act_id := lesson_id || '-q' || phase_order;
            INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload)
            VALUES (
              act_id,
              lesson_id,
              CASE
                WHEN lesson_doc->>'skill' = 'listening' AND phase_order = 1 THEN 'listening_choice'
                WHEN phase_order = 2 THEN 'grammar_fill_blank'
                WHEN phase_order = 3 THEN 'vocabulary_match'
                WHEN phase_order = 4 THEN 'sentence_ordering'
                ELSE 'multiple_choice'
              END,
              practice_count + phase_order,
              'quiz',
              CASE WHEN phase_order <= 2 THEN 'easy' WHEN phase_order <= 4 THEN 'medium' ELSE 'hard' END,
              true,
              CASE
                WHEN lesson_doc->>'skill' = 'listening' AND phase_order = 1 THEN jsonb_build_object(
                  'question','What is the main point of the listening seed for ' || (lesson_doc->>'focus') || '?',
                  'audioUrl','audio/placeholder-' || lower(level_code) || '.mp3',
                  'transcript','This placeholder script practises ' || (lesson_doc->>'focus') || ' and should be replaced by a full C-level script.',
                  'options',jsonb_build_array(
                    jsonb_build_object('id','a','text','The speaker uses nuanced language for a specific purpose'),
                    jsonb_build_object('id','b','text','The speaker lists unrelated words'),
                    jsonb_build_object('id','c','text','The speaker avoids context')
                  ),
                  'correctOptionId','a',
                  'explanationVi','Can thay bang audio/script C-level khi soan chi tiet.'
                )
                WHEN phase_order = 2 THEN jsonb_build_object(
                  'question','Fill the blank: Advanced users control ___ as well as grammar.',
                  'acceptedAnswers',jsonb_build_array('nuance','register','cohesion'),
                  'explanationVi','O cap C, sac thai, ngu vuc va lien ket deu quan trong.'
                )
                WHEN phase_order = 3 THEN jsonb_build_object(
                  'question','Match the lesson focus with its purpose.',
                  'pairs',jsonb_build_array(
                    jsonb_build_object('left',lesson_doc->>'focus','right',lesson_doc->>'canDo'),
                    jsonb_build_object('left','stance','right','speaker or writer position'),
                    jsonb_build_object('left','nuance','right','fine shade of meaning')
                  ),
                  'explanationVi','Kiem tra tu vung/chuc nang cua lesson.'
                )
                WHEN phase_order = 4 THEN jsonb_build_object(
                  'question','Order the sentence.',
                  'tokens',jsonb_build_array('Advanced','English','requires','precision'),
                  'correctOrder',jsonb_build_array(0,1,2,3),
                  'explanationVi','Advanced English requires precision.'
                )
                ELSE jsonb_build_object(
                  'question','Which answer best describes the can-do goal of this lesson?',
                  'options',jsonb_build_array(
                    jsonb_build_object('id','a','text',lesson_doc->>'canDo'),
                    jsonb_build_object('id','b','text','Memorise isolated words only'),
                    jsonb_build_object('id','c','text','Ignore context and register')
                  ),
                  'correctOptionId','a',
                  'explanationVi','Can-do cua lesson phai do duoc qua ngu canh.'
                )
              END
            );
          END LOOP;
        END IF;
      END LOOP;

      UPDATE learning_units SET review_lesson_id = review_id WHERE id = unit_id;
    END LOOP;
  END LOOP;
END $$;

UPDATE level_checkpoint_tests
   SET question_count = 32,
       pass_score = 75,
       required_unit_progress = 0.800,
       title = 'Kiểm tra cuối cấp C1'
 WHERE id = 'checkpoint-C1';

INSERT INTO level_checkpoint_tests (id, level_code, title, question_count, pass_score, required_unit_progress)
VALUES ('checkpoint-C2', 'C2', 'Chứng nhận hoàn thành C2', 36, 80, 0.800)
ON CONFLICT (level_code) DO UPDATE
SET title = EXCLUDED.title,
    question_count = EXCLUDED.question_count,
    pass_score = EXCLUDED.pass_score,
    required_unit_progress = EXCLUDED.required_unit_progress;
