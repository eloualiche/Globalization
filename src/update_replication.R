#!/usr/bin/env R
#! /usr/bin/env R
#
#
#
# =====================================================================


# =====================================================================
library(magrittr)
library(haven)
library(ggplot2)
library(wesanderson)
library(lubridate)
library(Hmisc)
library(stringr)
library(data.table)
library(statar)

library(WrdsR)
# =====================================================================


# =====================================================================
dt_base <- read_dta("./input/basereturns.dta") %>% data.table
dt_ret  <- dt_base[, .(permno, date, ret, SC_feenstra, q_SC_feenstra, mktcap1)]
dt_ret[, `:=`(y = year(date), m=as.character(month(date)))]
dt_ret[ str_length(m) < 2, m := paste0("0", m) ]
dt_ret[, date_ym := paste0(y, m) ]
dt_ret[, c("y", "m") := NULL ]
dt_ret[]
# =====================================================================


# =====================================================================
dt_firms <- dt_ret[, .(permno, date, date_ym, 
	ShippingCosts=SC_feenstra, q_SC=q_SC_feenstra)]
dt_firms <- dt_firms[ !is.na(q_SC) ]

fwrite(dt_firms, "./output/permno_SC.tsv", sep = "\t")
# =====================================================================


# =====================================================================
dt_SC <- dt_ret[, .(ew_ret = mean(ret/12, na.rm = T), vw_ret = wtd.mean(ret/12, weights=mktcap1, na.rm =T)), 
	by = .(date_ym, date, q_SC=q_SC_feenstra)]
dt_SC <- dt_SC[ !is.na(q_SC) ]
dt_SC[]

dt_SC <- merge(dt_SC[, datem := as.monthly(date)], 
	ff_factors[, .(datem=as.monthly(date), rf=as.numeric(RF)/100) ],
	by = c("datem"))
dt_SC[, c("date", "datem") := NULL ]

dt_SC <- dt_SC %>% dcast(date_ym + rf ~ q_SC, value.var = c("ew_ret", "vw_ret"))
dt_SC[, ew_ret_1_5 := ew_ret_1 - ew_ret_5]
dt_SC[, vw_ret_1_5 := vw_ret_1 - vw_ret_5]

fwrite(dt_SC, "./output/ShippingCosts_returns.tsv", sep = "\t")
# =====================================================================


# =====================================================================
