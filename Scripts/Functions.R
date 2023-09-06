

stat_calc = function(real, predicted) {
  
  require(Metrics)
  
  df = data.frame(real = real, predicted = predicted) %>% na.omit() %>% filter(real > 0 & predicted > 0)
  
  Y = log10(df$predicted/df$real)
  
  E = 100* (10^median(abs(Y))-1)
  BIAS_log_perc = 100* sign(median(Y))*(10^abs(median(Y))-1)
  
  bias = 10^mean(log10(df$predicted)-log10(df$real))
  
  MAPE = mean(abs((df$real-df$predicted)/df$real))*100
  
  MaE = 10^median(abs(log10(df$predicted)-log10(df$real)))
  
  pearSon = cor(df$real, df$predicted)
  
  RMSLE = rmsle(actual = df$real, predicted =df$predicted)
  N = nrow(df)
  SLOPE = lm(log(predicted)~log(real), data = df)$coefficients[2]
  
  
  
  resultados = data.frame(BIAS = bias, 
                          BIAS_perc = BIAS_log_perc,
                          MAPE = MAPE,
                          MAE = MaE,
                          R = pearSon, 
                          N = N, 
                          E = E,
                          RMSLE = RMSLE, 
                          slope = SLOPE)
  
  return(resultados)
  
}
