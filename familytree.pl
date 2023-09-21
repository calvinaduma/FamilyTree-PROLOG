%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ECE3520/CpSc3520 SDE1: Prolog Declarative and Logic Programming

% Use the following Prolog relations as a database of familial 
% relationships for 4 generations of people.  If you find obvious
% minor errors (typos) you may correct them.  You may add additional
% data if you like but you do not have to.

% Then write Prolog rules to encode the relations listed at the bottomG.
% You may create additional predicates as needed to accomplish this,
% including relations for debugging or extra relations as you desire.
% All should be included when you turn this in.  Your rules must be able
% to work on any data and across as many generations as the data specifies.
% They may not be specific to this data.

% Using SWI-Prolog, run your code, demonstrating that it works in all modes.
% Log this session and turn it in with your code in this (modified) file.
% You examples should demonstrate working across 4 generations where
% applicable.

% Fact recording Predicates:

% list of two parents, father first, then list of all children
% parent_list(?Parent_list, ?Child_list).

% Data:

parent_list([fred_smith, mary_jones],
            [tom_smith, lisa_smith, jane_smith, john_smith]).

parent_list([tom_smith, evelyn_harris],
            [mark_smith, freddy_smith, joe_smith, francis_smith]).

parent_list([mark_smith, pam_wilson],
            [martha_smith, frederick_smith]).

parent_list([freddy_smith, connie_warrick],
            [jill_smith, marcus_smith, tim_smith]).

parent_list([john_smith, layla_morris],
            [julie_smith, leslie_smith, heather_smith, zach_smith]).

parent_list([edward_thompson, susan_holt],
            [leonard_thompson, mary_thompson]).

parent_list([leonard_thompson, lisa_smith],
            [joe_thompson, catherine_thompson, john_thompson, carrie_thompson]).

parent_list([joe_thompson, lisa_houser],
            [lilly_thompson, richard_thompson, marcus_thompson]).

parent_list([john_thompson, mary_snyder],
            []).

parent_list([jeremiah_leech, sally_swithers],
            [arthur_leech]).

parent_list([arthur_leech, jane_smith],
            [timothy_leech, jack_leech, heather_leech]).

parent_list([robert_harris, julia_swift],
            [evelyn_harris, albert_harris]).

parent_list([albert_harris, margaret_little],
            [june_harris, jackie_harrie, leonard_harris]).

parent_list([leonard_harris, constance_may],
            [jennifer_harris, karen_harris, kenneth_harris]).

parent_list([beau_morris, jennifer_willis],
            [layla_morris]).

parent_list([willard_louis, missy_deas],
            [jonathan_louis]).

parent_list([jonathan_louis, marsha_lang],
            [tom_louis]).

parent_list([tom_louis, catherine_thompson],
            [mary_louis, jane_louis, katie_louis]).

%Rules:


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SWE1 Assignment - Create rules for:

% the Parent is the parent - mother or father of the child
% parent(?Parent, ?Child).
parent(Parent,Child) :- parent_list(ParentList, ChildList), member(Parent, ParentList), member(Child,ChildList).

% Husband is married to Wife - note the order is significant
% This is found in the first list of the parent_list predicate
% married(?Husband, ?Wife).
married(Husband, Wife) :- parent_list(ParentList,_), member(Husband, ParentList), member(Wife, ParentList).

% Ancestor is parent, grandparent, great-grandparent, etc. of Person
% Order is significant.  This looks for chains between records in the parent_list data
% ancestor(?Ancestor, ?Person).
ancestor(Ancestor, Person) :- parent(Ancestor, Person).
ancestor(Ancestor, Person) :- parent(Parent, Person), ancestor(Ancestor, Parent).

% Really the same as ancestor, only backwards.  May be more convenient in some cases.
% descendent(?Decendent, ?Person).
descendent(Descendent, Person) :- parent(Person, Parent), descendent(Descendent, Parent).
descendent(Descendent, Person) :- ancestor(Person, Descendent).

% There are exactly Gen generations between Ancestor and Person.  Person and parent 
% have a Gen of 1.  The length of the chain (or path) from Person to Ancestor.
% Again order is significant.
% generations(?Ancesstor, ?Person, ?Gen).
generations(Ancestor, Ancestor, 0).
generations(Ancestor, Person, Gen) :- parent(Parent, Person), generations(Ancestor, Parent, GenParent), Gen is GenParent + 1.

% Ancestor is the ancestor of both Person1 and Person2.  There must not exist another
% common ancestor that is fewer generations. 
% least_common_ancestor(?Person1, ?Person2, ?Ancestor).
least_common_ancestor(Person1, Person2, Ancestor) :- ancestor(Ancestor, Person1), ancestor(Ancestor, Person2), 
    not((ancestor(OtherAncestor, Person1), ancestor(OtherAncestor, Person2), generations(OtherAncestor, Person1, Gen1), 
    generations(OtherAncestor, Person2, Gen2), Gen1 < Gen2)).

% Do Person1 and Person2 have a common ancestor?
% blood(?Person1, ?Person2). %% blood relative
blood(Person1, Person2) :- ancestor(Ancestor, Person1), ancestor(Ancestor, Person2).

% Are Person1 and Person2 on the same list 2nd are of a parent_list record.
% sibling(?Person1, Person2).
sibling(Person1, Person2) :- parent(Parent, Person1), parent(Parent, Person2), Person1 = Person2.
%%sibling(Person1, Person2) :- parent(Parent1, Person1), parent(Parent2, Person2), Parent1 = Parent2.

% These are pretty obvious, and really just capturing info we already can get - except that
% the gender is important.  Note that father is always first on the list in parent_list.
% father(?Father, ?Child).
father(Father, Child) :- parent_list([Father|_], Children), member(Child, Children).

% mother(?Mother, ?Child).
mother(Mother, Child) :- parent_list([_, Mother], Children), member(Child, Children).

% Note that some uncles may not be in a parent list arg of parent_list, but would have 
% a male record to specify gender.
% uncle(?Uncle, ?Person). %% 
uncle(Uncle, Person) :- mother(Mother, Person), sibling(Uncle, Mother), parent_list([Husband|_],_), Husband = Uncle.
uncle(Uncle, Person) :- father(Father, Person), sibling(Uncle, Father).
% aunt(?Aunt, ?Person). %% 
aunt(Aunt, Person) :- father(Father, Person), sibling(Aunt, Father), parent_list([_|Wife],_), Wife = Aunt.
aunt(Aunt, Person) :- mother(Mother, Person), sibling(Aunt, Mother).

% cousins have a generations greater than parents and aunts/uncles.
% cousin(?Cousin, ?Person).
cousin(Cousin, Person) :- parent_list(Parents, _), (father(_, Person) ; mother(_, Person)), member(Parent, Parents),
    sibling(Parent, Sibling), (father(Sibling, Cousin) ; mother(Sibling, Cousin)).

%% 1st cousin, 2nd cousin, 3rd once removed, etc.
% cousin_type(+Person1, +Person2, -CousinType, -Removed).
