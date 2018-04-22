-> game_start

VAR time = 0.0
VAR resources = 5

LIST locations = meadow, woods, rocks, alien_base, artifact

VAR found_locations = ()
VAR hq = false

== function all_found()
    ~return LIST_COUNT(found_locations) == LIST_COUNT(locations)

VAR idle_scouts = 1
VAR idle_messengers = 1
VAR idle_knights = 3
VAR idle_archers = 3
VAR idle_peasents = 5

== function has_idle()
    ~return idle_scouts || idle_messengers || idle_knights || idle_archers || idle_peasents

LIST quantities = single, few, squad, section, platoon, company

=== function num_to_quantity(x)
    {
    - x == 1: ~return single
    - x < 5 : ~return few
    - x < 10: ~return squad
    - x < 50: ~return platoon
    - else  : ~return company
    }

=== function print_quantity_of(x, of)
    {
        - x == 1: {num_to_quantity(x)} {of}
        - x < 5 : {num_to_quantity(x)} {of}s
        - else: {num_to_quantity(x)} of {of}s
    }


=== game_start ===
- The peasants have been rumbling about something in the woods to the west of New Kingstown.
*   You dismiss it as superstitious hogwash[.] but the King orders you to investigate either way.
*   You volunteer to lead an expidition[.], assembling some of your best men.
-   A fortnight later you are in New Kingston, making final preperations before setting out into the woods. Once everything is to your liking you declare that you shall depart in the morning. With you last night in civilization you decide to <>
*   party with your troops.
    - - The next day you set out with a thrubbing head, but moral is high.
*   spend some alone time in the shadier part of town.
    - - The next day you set out in good spirits, with a couple portable vices to keep them that way.
*   consult once more with the locals[.] regarding the reports coming form the woods.
    - - The next day you set out feeling a little bit more prepared for what you might find.
-   It takes the better part of a week treking through the woods to find the region that the townsfolk soke of. You see no obvious sign of threat, so begin looking for a place to make camp.
*   You seek out the most defensible location[.] and come accross a rocky hill with good lines of sight.
    ~ hq = rocks
*   You ask your agriculture expert for his recomendation[.] and are lead to a nice flowery meadow.
    ~ hq = meadow
*   You grab a bottle and walk in a random direction[.] stopping when the bottle is empty and declaring that your camp shall be here.
    ~ hq = woods
-   ~ found_locations += hq
    ~ time = 0.0
    -> menu.orders

=== status ===
'Greetings Commander. It is {time} o'clock. We currently have <>
{idle_scouts: a {print_quantity_of(idle_scouts, "idle scout")}, <>}
{idle_messengers: a {print_quantity_of(idle_messengers, "idle messenger")}, <>}
{idle_knights: a {print_quantity_of(idle_knights, "idle knight")}, <>}
{idle_archers: a {print_quantity_of(idle_archers, "idle archer")}, <>}
{idle_peasents: a {print_quantity_of(idle_peasents, "idle peasent")}, <>}
{has_idle(): and }{print_num(resources)} resources available. <>
-> DONE


=== menu ===
<- status
+ Issue orders -> orders
+ Train units -> training
+ Construct buildings -> construction
+ Wait -> menu

= orders
<- status
* {idle_messengers} Report your home base location back to New Kingstown.
+ {idle_scouts && not all_found()} Send a scout exploring.
    ~idle_scouts -= 1
    
    {~{LIST_ALL(locations) - found_locations}}
    -> menu
+ Wait -> menu

= training
+ Train scout
+ Train knight
+ Train messenger
+ Wait -> menu

= construction

+ Wait -> menu


=== unused ===
    "News from the front M'Lord! Sir James reports barbarians ammasing in the woods. He requests immediate assistance!"
*   Send a battalion of our finest knights!
    'What is the purpose of our journey, Monsieur?'
    'A wager,' he replied.
    * *     'A wager!'[] I returned.
            He nodded. 
            * * *   'But surely that is foolishness!'
            * * *  'A most serious matter then!'
            - - -   He nodded again.
            * * *   'But can we win?'
                    'That is what we will endeavour to find out,' he answered.
            * * *   'A modest wager, I trust?'
                    'Twenty thousand pounds,' he replied, quite flatly.
            * * *   I asked nothing further of him then[.], and after a final, polite cough, he offered nothing more to me. <>
    * *     'Ah[.'],' I replied, uncertain what I thought.
    - -     After that, <>
*   How dare you interrupt my dinner for such hogwash!
- we passed the day in silence.
- -> END



=== function print_num(x) ===
{ 
    - x >= 1000:
        {print_num(x / 1000)} thousand { x mod 1000 > 0:{print_num(x mod 1000)}}
    - x >= 100:
        {print_num(x / 100)} hundred { x mod 100 > 0:and {print_num(x mod 100)}}
    - x == 0:
        zero
    - else:
        { x >= 20:
            { x / 10:
                - 2: twenty
                - 3: thirty
                - 4: forty
                - 5: fifty
                - 6: sixty
                - 7: seventy
                - 8: eighty
                - 9: ninety
            }
            { x mod 10 > 0:<>-<>}
        }
        { x < 10 || x > 20:
            { x mod 10:
                - 1: one
                - 2: two
                - 3: three
                - 4: four        
                - 5: five
                - 6: six
                - 7: seven
                - 8: eight
                - 9: nine
            }
        - else:     
            { x:
                - 10: ten
                - 11: eleven       
                - 12: twelve
                - 13: thirteen
                - 14: fourteen
                - 15: fifteen
                - 16: sixteen      
                - 17: seventeen
                - 18: eighteen
                - 19: nineteen
            }
        }
}