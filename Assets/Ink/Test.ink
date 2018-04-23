-> game_start

VAR time = 0.0

LIST locations = meadow, woods, rocks, alien_base, artifact

VAR found_locations = ()
VAR hq = false

== function all_found()
    ~return LIST_COUNT(found_locations) == LIST_COUNT(locations)

LIST quantities = single=1, few=5, squad=10, section=25, platoon=50, company=200

=== function num_to_quantity(x)
    {
    - x == 1: ~return single
    - x <= LIST_VALUE(few): ~return few
    - x <= LIST_VALUE(squad): ~return squad
    - x <= LIST_VALUE(section): ~return section
    - x <= LIST_VALUE(platoon): ~return platoon
    - else  : ~return company
    }

=== function print_quantity_of(x, of)
    {
        - x == 1: {num_to_quantity(x)} {of}
        - x <= LIST_VALUE(few) : {num_to_quantity(x)} {of}s
        - else: {num_to_quantity(x)} of {of}s
    }

EXTERNAL trunc(x)
=== function trunc(x)
~ return 5

VAR scouts = 1
VAR messengers = 1
VAR knights = 3
VAR archers = 3
VAR peasents = 5

VAR idle_scouts = 1
VAR idle_messengers = 1
VAR idle_knights = 3
VAR idle_archers = 3
VAR idle_peasents = 5

=== function has_idle()
    ~return idle_scouts || idle_messengers || idle_knights || idle_archers || idle_peasents

=== function can_train_any()
    ~return can_train_messengers(single) || can_train_knights(single) || can_train_archers(single) || can_train_scouts(single)

=== function can_train_scouts(quantity)
    ~return idle_peasents >= LIST_VALUE(quantity) && resources >= scout_cost * LIST_VALUE(quantity) && supply_used - LIST_VALUE(quantity) * peasant_supply + LIST_VALUE(quantity) * scout_supply <= supply

=== function print_scout_train(quantity)
    {print_quantity_of(LIST_VALUE(single), "scout")} ({print_num(scout_cost * LIST_VALUE(quantity))} resources)

=== function train_scout(number)
    ~scouts += number
    ~idle_scouts += number
    
=== function can_train_messengers(quantity)
    ~return idle_peasents >= LIST_VALUE(quantity) && resources >= messenger_cost * LIST_VALUE(quantity) && supply_used - LIST_VALUE(quantity) * peasant_supply + LIST_VALUE(quantity) * messenger_supply <= supply

=== function print_messenger_train(quantity)
    {print_quantity_of(LIST_VALUE(single), "messenger")} ({print_num(messenger_cost * LIST_VALUE(quantity))} resources)

=== function train_messenger(number)
    ~messengers += number
    ~idle_messengers += number
    
 === function can_train_knights(quantity)
    ~return idle_peasents >= LIST_VALUE(quantity) && resources >= knight_cost * LIST_VALUE(quantity) && supply_used - LIST_VALUE(quantity) * peasant_supply + LIST_VALUE(quantity) * knight_supply <= supply

=== function print_knight_train(quantity)
    {print_quantity_of(LIST_VALUE(single), "knight")} ({print_num(knight_cost * LIST_VALUE(quantity))} resources)

=== function train_knight(number)
    ~knights += number
    ~idle_knights += number

=== function can_train_archers(quantity)
    ~return idle_peasents >= LIST_VALUE(quantity) && resources >= archer_cost * LIST_VALUE(quantity) && supply_used - LIST_VALUE(quantity) * peasant_supply + LIST_VALUE(quantity) * archer_supply <= supply

=== function print_archer_train(quantity)
    {print_quantity_of(LIST_VALUE(single), "archer")} ({print_num(archer_cost * LIST_VALUE(quantity))} resources)

=== function train_archer(number)
    ~archers += number
    ~idle_archers += number

VAR scout_cost = 10
VAR messenger_cost = 10
VAR knight_cost = 10
VAR archer_cost = 10

VAR scout_time = 10
VAR messenger_time = 10
VAR knight_time = 10
VAR archer_time = 10

VAR supply = 25
VAR scout_supply = 0
VAR messenger_supply = 2
VAR knight_supply = 3
VAR archer_supply = 2
VAR peasant_supply = 1

=== function supply_used()
    ~ return scouts * scout_supply + messengers * messenger_supply + knights * knight_supply + archers * archer_supply + peasents * peasant_supply

VAR resources = 0
VAR resource_delta = 0.0
VAR resource_rate = 0

=== function add_resources(x)
    ~ resources += x

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
    ~ time = 3.5
    ~ resources = 10
    ~ resource_delta = 5.0
    ~ resource_rate = 1
    -> menu

=== status ===
'Greetings Commander. It is {print_num(trunc(time) % 24)} o'clock.
<- urgent
We currently have <>
{idle_scouts: a {print_quantity_of(idle_scouts, "idle scout")}, <>}
{idle_messengers: a {print_quantity_of(idle_messengers, "idle messenger")}, <>}
{idle_knights: a {print_quantity_of(idle_knights, "idle knight")}, <>}
{idle_archers: a {print_quantity_of(idle_archers, "idle archer")}, <>}
{idle_peasents: a {print_quantity_of(idle_peasents, "idle peasent")}, <>}
{has_idle(): and }{print_num(resources)} resources available.
We are using {print_num(supply_used())} of our {print_num(supply)} supply.
-> DONE

=== function has_urgent()
    ~return false

=== urgent ===
{show_johnsons_safe: <- johnsons.safe}

=== menu ===
<- status
+ {not has_urgent()} Issue orders -> orders
+ {not has_urgent() && can_train_any()}Train units -> training
+ {not has_urgent()} Construct buildings -> construction
+ {not has_urgent()} Make it rain! -> menu # async #add_resources # 10 # 10
+ {not has_urgent()} Wait -> menu



VAR johnsons_found = false
VAR smiths_found = false
VAR bobs_found = false

=== orders ===
<- status
What orders shall you give?
* {idle_messengers} Report your home base location back to New Kingstown. #async #reinforcements #120
    ~idle_messengers -= 1
    -> menu
* {idle_scouts && not johnsons_found && time < 30} Send a scout exploring. #async #find_johnsons #10
    ~idle_scouts -= 1
    -> menu
+ Nevermind -> menu

VAR show_reinforcements_from_town = false
=== function reinforcements
~   show_reinforcements_from_town = true
~   idle_messengers += 1
~   idle_knights += 5
~   idle_archers += 10
~   idle_peasents += 30

VAR show_johnsons_safe = false
=== function find_johnsons
~   johnsons_found = true
~   show_johnsons_safe = true
~   idle_scouts += 1

=== johnsons ===
= safe
    Your scouts returned. They reported finding a family living in a small homestead not far from here.
    ~show_johnsons_safe = false
    -> DONE








=== training ===
<- status
+ {can_train_scouts(single)}Train scouts -> scout_training
+ {can_train_knights(single)}Train knight -> knight_training
+ {can_train_archers(single)}Train archer -> archer_training
+ {can_train_messengers(single)}Train messenger -> messenger_training
+ Nevermind -> menu

= scout_training
<- status
How many scouts would you like to train?
+ {can_train_scouts(single)} A {print_scout_train(single)} #async #train #single #scout
    ~resources -= LIST_VALUE(single)*scout_cost
    ~idle_peasents -= LIST_VALUE(single)
+ {can_train_scouts(few)} A {print_scout_train(few)} #async #train #few #scout
    ~resources -= LIST_VALUE(few)*scout_cost
    ~idle_peasents -= LIST_VALUE(few)
+ {can_train_scouts(squad)} A {print_scout_train(squad)} #async #train #squad #scout
    ~resources -= LIST_VALUE(squad)*scout_cost
    ~idle_peasents -= LIST_VALUE(squad)
+ {can_train_scouts(section)} A {print_scout_train(section)} #async #train #section #scout
    ~resources -= LIST_VALUE(section)*scout_cost
    ~idle_peasents -= LIST_VALUE(section)
+ {can_train_scouts(platoon)} A {print_scout_train(platoon)} #async #train #platoon #scout
    ~resources -= LIST_VALUE(platoon)*scout_cost
    ~idle_peasents -= LIST_VALUE(platoon)
+ {can_train_scouts(company)} A {print_scout_train(company)} #async #train #company #scout
    ~resources -= LIST_VALUE(company)*scout_cost
    ~idle_peasents -= LIST_VALUE(company)
+ Nevermind -> menu
-   ->menu

= messenger_training
<- status
How many messengers would you like to train?
+ {can_train_messengers(single)} A {print_messenger_train(single)} #async #train #single #messenger
    ~resources -= LIST_VALUE(single)*messenger_cost
    ~idle_peasents -= LIST_VALUE(single)
+ {can_train_messengers(few)} A {print_messenger_train(few)} #async #train #few #messenger
    ~resources -= LIST_VALUE(few)*messenger_cost
    ~idle_peasents -= LIST_VALUE(few)
+ {can_train_messengers(squad)} A {print_messenger_train(squad)} #async #train #squad #messenger
    ~resources -= LIST_VALUE(squad)*messenger_cost
    ~idle_peasents -= LIST_VALUE(squad)
+ {can_train_messengers(section)} A {print_messenger_train(section)} #async #train #section #messenger
    ~resources -= LIST_VALUE(section)*messenger_cost
    ~idle_peasents -= LIST_VALUE(section)
+ {can_train_messengers(platoon)} A {print_messenger_train(platoon)} #async #train #platoon #messenger
    ~resources -= LIST_VALUE(platoon)*messenger_cost
    ~idle_peasents -= LIST_VALUE(platoon)
+ {can_train_messengers(company)} A {print_messenger_train(company)} #async #train #company #messenger
    ~resources -= LIST_VALUE(company)*messenger_cost
    ~idle_peasents -= LIST_VALUE(company)
+ Nevermind -> menu
-   ->menu

= knight_training
<- status
How many knights would you like to train?
+ {can_train_knights(single)} A {print_knight_train(single)} #async #train #single #knight
    ~resources -= LIST_VALUE(single)*knight_cost
    ~idle_peasents -= LIST_VALUE(single)
+ {can_train_knights(few)} A {print_knight_train(few)} #async #train #few #knight
    ~resources -= LIST_VALUE(few)*knight_cost
    ~idle_peasents -= LIST_VALUE(few)
+ {can_train_knights(squad)} A {print_knight_train(squad)} #async #train #squad #knight
    ~resources -= LIST_VALUE(squad)*knight_cost
    ~idle_peasents -= LIST_VALUE(squad)
+ {can_train_knights(section)} A {print_knight_train(section)} #async #train #section #knight
    ~resources -= LIST_VALUE(section)*knight_cost
    ~idle_peasents -= LIST_VALUE(section)
+ {can_train_knights(platoon)} A {print_knight_train(platoon)} #async #train #platoon #knight
    ~resources -= LIST_VALUE(platoon)*knight_cost
    ~idle_peasents -= LIST_VALUE(platoon)
+ {can_train_knights(company)} A {print_knight_train(company)} #async #train #company #knight
    ~resources -= LIST_VALUE(company)*knight_cost
    ~idle_peasents -= LIST_VALUE(company)
+ Nevermind -> menu
-   ->menu

= archer_training
<- status
How many archers would you like to train?
+ {can_train_archers(single)} A {print_archer_train(single)} #async #train #single #archer
    ~resources -= LIST_VALUE(single)*archer_cost
    ~idle_peasents -= LIST_VALUE(single)
+ {can_train_archers(few)} A {print_archer_train(few)} #async #train #few #archer
    ~resources -= LIST_VALUE(few)*archer_cost
    ~idle_peasents -= LIST_VALUE(few)
+ {can_train_archers(squad)} A {print_archer_train(squad)} #async #train #squad #archer
    ~resources -= LIST_VALUE(squad)*archer_cost
    ~idle_peasents -= LIST_VALUE(squad)
+ {can_train_archers(section)} A {print_archer_train(section)} #async #train #section #archer
    ~resources -= LIST_VALUE(section)*archer_cost
    ~idle_peasents -= LIST_VALUE(section)
+ {can_train_archers(platoon)} A {print_archer_train(platoon)} #async #train #platoon #archer
    ~resources -= LIST_VALUE(platoon)*archer_cost
    ~idle_peasents -= LIST_VALUE(platoon)
+ {can_train_archers(company)} A {print_archer_train(company)} #async #train #company #archer
    ~resources -= LIST_VALUE(company)*archer_cost
    ~idle_peasents -= LIST_VALUE(company)
+ Nevermind -> menu
-   ->menu


=== construction ===
<- status
+ Nevermind -> menu


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