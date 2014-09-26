library('arules')
#Apriori in R for Dota 2 Hero comp

#import the data
hero = na.omit(read.csv('MasterHeroComp.csv'))
heroID = na.omit(read.csv('HeroID.csv'))

hero$WinvsLoss = as.character(hero$WinvsLoss)
hero$Hero1 = factor(hero$Hero1, levels = heroID$ID, labels = heroID$Hero)
hero$Hero2 = factor(hero$Hero2, levels = heroID$ID, labels = heroID$Hero)
hero$Hero3 = factor(hero$Hero3, levels = heroID$ID, labels = heroID$Hero)
hero$Hero4 = factor(hero$Hero4, levels = heroID$ID, labels = heroID$Hero)
hero$Hero5 = factor(hero$Hero5, levels = heroID$ID, labels = heroID$Hero)

#remove wins/lose column
hero.comp = hero[,-1]

#Get data into a format that arules can use
#create empty list variable
num = length(hero[,1]) #get number of games
hero.comp.raw = matrix(nrow = num, ncol = 1)insta
hero.win.raw = matrix(nrow = num, ncol =1)
#put each row into each space in the variable
for (i in 1:num) {
    team = (c(hero.comp[i,1], hero.comp[i,2], hero.comp[i,3], hero.comp[i,4], hero.comp[i,5]))
    hero.comp.raw[i] = list(team)
}

for (i in 1:num) {
    teamwin = (c(hero[i,1], hero[i,2], hero[i,3], hero[i,4], hero[i,5], hero[i,6]))
    hero.win.raw[i] = list(teamwin)
}
#convert to 'transaction' variable type
hero.transaction = as(hero.comp.raw, 'transactions')
hero.win.transaction = as(hero.win.raw, 'transactions')

#create a histogram of the frequency of picks
itemFrequencyPlot(hero.transaction,topN=20,type="absolute")

#create the apriori
team.rules = apriori(hero.transaction, parameter = list(support = 0.001, maxlen = 2))
team.sorted = sort(team.rules, decreasing = TRUE, by = 'lift')
inspect(team.sorted[1:20])

#create a targeted apriori that checks what picks are likely given chosen pick (9 is used here as an example)
pick.rules = apriori(hero.transaction, parameter = list(support = 0.001, conf = 0, minlen = 2), appearance = list(default = 'rhs', lhs = '9'), control = list(verbose = F))
pick.sorted = sort(pick.rules, decreasing = TRUE, by = 'confidence')
inspect(pick.sorted[1:10])

#find which team comps lead to the highest probability of winning with at least 1% of total games
win.rules = apriori(hero.win.transaction, parameter = list(support = 0.005, conf = 0, minlen = 3), appearance = list(rhs = c(WinvsLoss = 'Win'), default = 'lhs'), control = list(verbose = F))
win.sorted = sort(win.rules, decreasing = TRUE, by = 'support')
inspect(win.sorted[1:50])
