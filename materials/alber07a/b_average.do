drop b_average
by iso3166_2 strat, sort: gen b_average=sum(b)/[_N]
by iso3166_2 strat, sort: replace b_average=b_average[_N]
