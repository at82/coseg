pattern <- paste0(
  "=(?<fun>.*?)\n",
  "(?<table>",
  "(?:[^=].*?\n)*",
  ")")
library(namedCapture)
library(data.table)
library(ggplot2)
ploss <- function(dt, x){
  ## need to make a new data table, otherwise ifelse may only get one
  ## element, and return only one element.
  new.dt <- data.table(dt, x)
  new.dt[, ifelse(Log==0, 0, Log*log(x)) + Linear*x + Constant]
}
getLines <- function(dt){
  line.list <- list()
  for(piece.i in 1:nrow(dt)){
    piece <- dt[piece.i,]
    mean.vec <- piece[, seq(exp(min_log_mean), exp(max_log_mean), l=1000)]
    line.list[[piece.i]] <- data.table(
      piece.i,
      piece,
      mean=mean.vec,
      log.mean=log(mean.vec),
      cost=ploss(piece, mean.vec))
  }
  do.call(rbind, line.list)
}
gdata <- function(txt){
  mat <- str_match_all_named(txt, pattern)[[1]]
  funs.list <- list()
  vlines.list <- list()
  for(row.i in 1:nrow(mat)){
    r <- mat[row.i,]
    df <- read.table(text=r[["table"]], header=TRUE)
    dt <- data.table(df)
    l <- getLines(dt)
    fun <- r[["fun"]]
    funs.list[[row.i]] <- data.table(fun, l)
    if(1 < nrow(dt)){
      vlines.list[[row.i]] <- data.table(fun, dt[-1,])
    }
  }
  list(
    funs=do.call(rbind, funs.list),
    vlines=do.call(rbind, vlines.list))
}

C11.301minless <- gdata("
=prev cost model
    Linear        Log   Constant min_log_mean max_log_mean     data_i
        22          0 -19706.460691       -inf  -1.917963 299
        71        -49 -19807.639270  -1.917963   0.370000 298
       402       -797 -20010.079492   0.370000   0.445068 286
       421       -844 -20018.812620   0.445068   0.850674 284
       439       -898 -20015.018261   0.850674   0.865637 283
      1097      -3300 -19499.507878   0.865637   1.127393 238
      1098      -3309 -19492.448939   1.127393   1.414200 237
      1100      -3329 -19472.391333   1.414200   1.482339 236
        71        -49 -19803.536430   1.482339   3.496508 299
=min prev cost
    Linear        Log   Constant min_log_mean max_log_mean     data_i
         0          0 -19706.460691       -inf  -1.833168 300
        71        -49 -19807.639270  -1.833168  -0.370860 300
         0          0 -19740.467150  -0.370860   0.461754 300
       421       -844 -20018.812620   0.461754   0.695520 300
         0          0 -19761.831214   0.695520   0.884747 300
      1097      -3300 -19499.507878   0.884747   1.101343 300
         0          0 -19833.940726   1.101343   3.496508 300
")
ggplot()+
  geom_vline(xintercept=log(2.85))+
  geom_vline(xintercept=0.656780)+
  coord_cartesian(xlim=c(0,2), ylim=c(-20000, -19500))+
  geom_vline(aes(xintercept=min_log_mean, color=fun),
             data=C11.301minless$vlines)+
  geom_line(aes(log.mean, cost, color=fun),
            size=2,
            data=C11.301minless$funs)

C11.301minenv <- gdata("
=min prev cost
    Linear        Log   Constant min_log_mean max_log_mean     data_i
         0          0 -19706.460691       -inf  -1.833168 300
        71        -49 -19807.639270  -1.833168  -0.370860 300
         0          0 -19740.467150  -0.370860   0.461754 300
       421       -844 -20018.812620   0.461754   0.695520 300
         0          0 -19761.831214   0.695520   0.884747 300
      1097      -3300 -19499.507878   0.884747   1.101343 300
         0          0 -19833.940726   1.101343   3.496508 300
=cost model
    Linear        Log   Constant min_log_mean max_log_mean     data_i
        71        -49 -19807.639270       -inf   0.000000 299
        22          0 -19758.639270   0.000000   0.309734 299
       213       -499 -19864.426823   0.309734   0.930885 293
      1097      -3300 -19499.507878   0.930885   1.121603 299
        22          0 -19900.793841   1.121603   3.496508 299
=new cost model
    Linear        Log   Constant min_log_mean max_log_mean     data_i
         0          0 -19706.460691       -inf  -1.833168 300
        71        -49 -19807.639270  -1.833168  -0.370860 300
         0          0 -19740.467150  -0.370860   0.368836 300
       213       -499 -19864.426823   0.368836   0.930885 293
      1097      -3300 -19499.507878   0.930885   1.101343 300
         0          0 -19833.940726   1.101343   3.496508 300
")
ggplot()+
  geom_vline(xintercept=log(2.85))+
  geom_vline(xintercept=0.656780)+
  coord_cartesian(xlim=c(0,2), ylim=c(-20000, -19500))+
  geom_vline(aes(xintercept=min_log_mean, color=fun),
             data=C11.301minenv$vlines)+
  geom_line(aes(log.mean, cost, color=fun),
            size=2,
            data=C11.301minenv$funs)
## The min comes from (should not be here)
##        213       -499 -19864.426823   0.368836   0.930885 293

C11.301 <- gdata("
=new cost model
    Linear        Log   Constant min_log_mean max_log_mean     data_i
        95        -95 -19706.460691       -inf  -1.833168 300
       166       -144 -19807.639270  -1.833168  -0.370860 300
        95        -95 -19740.467150  -0.370860   0.368836 300
       308       -594 -19864.426823   0.368836   0.930885 293
      1192      -3395 -19499.507878   0.930885   1.101343 300
        95        -95 -19833.940726   1.101343   3.496508 300
")
ggplot()+
  geom_vline(xintercept=log(2.85))+
  coord_cartesian(xlim=c(-1,2), ylim=c(-19700, -19600))+
  geom_vline(aes(xintercept=min_log_mean, color=fun),
             data=C11.301$vlines)+
  geom_line(aes(log.mean, cost, color=fun),
            size=2,
            data=C11.301$funs)+
  geom_point(aes(x=0.656780, y=-19660.553868))

## prev cost model is C10.293.
C11.294minless <- gdata("
=prev cost model
    Linear        Log   Constant min_log_mean max_log_mean     data_i
        40          0 -19864.426823       -inf  -2.005918 292
        57        -17 -19900.814557  -2.005918   0.042381 291
       105       -113 -19946.823999   0.042381   0.228953 290
       189       -298 -20010.079492   0.228953   0.445068 286
       208       -345 -20018.812620   0.445068   0.850674 284
       226       -399 -20015.018261   0.850674   0.865637 283
       884      -2801 -19499.507878   0.865637   1.127393 238
       885      -2810 -19492.448939   1.127393   1.414200 237
       887      -2830 -19472.391333   1.414200   1.568696 236
        57        -17 -19900.814557   1.568696   3.496508 292
=min prev cost
    Linear        Log   Constant min_log_mean max_log_mean     data_i
         0          0 -19864.426823       -inf   0.930885 293
       884      -2801 -19499.507878   0.930885   1.127393 293
       885      -2810 -19492.448939   1.127393   1.155352 293
         0          0 -19928.988388   1.155352   3.496508 293
")
ggplot()+
  geom_vline(xintercept=0.656780)+
  geom_vline(xintercept=log(2.85))+
  coord_cartesian(ylim=c(-20000, -19800))+
  geom_vline(aes(xintercept=min_log_mean, color=fun),
             data=C11.294minless$vlines)+
  geom_line(aes(log.mean, cost, color=fun),
            size=2,
            data=C11.294minless$funs)
## Is there a problem with creating a constant segment on the left?

C153.370minless <- gdata("
=prev cost model
    Linear        Log        Constant    min_log_mean    max_log_mean   prev_log_mean data_i
         5         -9   -20936.673374            -inf        0.000000             inf 368
        54        -58   -20985.673374        0.000000        0.072759             inf 368
         1         -1   -20932.820658        0.072759        3.496508        0.072759 368
=min prev cost
    Linear        Log        Constant    min_log_mean    max_log_mean   prev_log_mean data_i
         0          0   -20931.817994            -inf        0.071459        0.071459 369
        54        -58   -20985.673374        0.071459        0.072759             inf 369
         1         -1   -20932.820658        0.072759        3.496508             inf 369
")
ggplot()+
  geom_vline(aes(xintercept=min_log_mean, color=fun),
             data=C153.370minless$vlines)+
  geom_line(aes(log.mean, cost, color=fun),
            size=2,
            data=C153.370minless$funs)

C153.370minenv <- gdata("
=min prev cost
    Linear        Log        Constant    min_log_mean    max_log_mean   prev_log_mean data_i
         0          0   -20931.817994            -inf        0.071459        0.071459 369
        54        -58   -20985.673374        0.071459        0.072759             inf 369
         1         -1   -20932.820658        0.072759        3.496508             inf 369
=cost model
    Linear        Log        Constant    min_log_mean    max_log_mean   prev_log_mean data_i
         1         -1   -20932.820658            -inf        0.072759        0.072759 368
        54        -58   -20985.673374        0.072759        0.438176             inf 368
         1         -1   -20928.505894        0.438176        0.693147        0.693147 368
         5         -9   -20930.960717        0.693147        3.496508             inf 368
=new cost model
    Linear        Log        Constant    min_log_mean    max_log_mean   prev_log_mean data_i
         0          0   -20931.817994            -inf       -0.073882        0.071459 369
         1         -1   -20932.820658       -0.073882        3.496508        0.072759 368
")
ggplot()+
  ##coord_cartesian(xlim=c(-1, 1), ylim=c(-20900, -20897.5))+
  geom_vline(aes(xintercept=min_log_mean, color=fun),
             data=C153.370minenv$vlines)+
  geom_line(aes(log.mean, cost, color=fun),
            size=2,
            data=C153.370minenv$funs)


C153.370 <- gdata("
=min less
    Linear        Log        Constant    min_log_mean    max_log_mean   prev_log_mean data_i
2.027404e-07 -2.027404e-06       -0.445946            -inf        0.560052             inf 256605
6.082213e-07 -5.676732e-06       -0.445944        0.560052        1.189710             inf 256605
1.621924e-06 -1.682746e-05       -0.445934        1.189710        1.439225             inf 256605
2.027404e-06 -2.169323e-05       -0.445929        1.439225        1.657712             inf 256605
4.054809e-06 -4.804948e-05       -0.445896        1.657712        1.851359             inf 256605
5.473992e-06 -6.791805e-05       -0.445868        1.851359        1.935793             inf 256605
2.331515e-05 -3.270203e-04       -0.445490        1.935793        2.008718             inf 256605
2.351789e-05 -3.300614e-04       -0.445486        2.008718        2.168541             inf 256605
2.372063e-05 -3.333053e-04       -0.445480        2.168541        2.271006             inf 256605
2.574804e-05 -3.671629e-04       -0.445423        2.271006        2.446261             inf 256605
2.655900e-05 -3.817603e-04       -0.445397        2.446261        2.456292             inf 256605
3.101929e-05 -4.624509e-04       -0.445251        2.456292        2.567157             inf 256605
3.122203e-05 -4.663030e-04       -0.445243        2.567157        2.681841             inf 256605
3.264121e-05 -4.946867e-04       -0.445188        2.681841        2.718349             inf 256605
0.000000e+00 0.000000e+00       -0.446038        2.718349        4.691348        2.718349 256605
=prev up cost
    Linear        Log        Constant    min_log_mean    max_log_mean   prev_log_mean data_i
6.082213e-07 -5.676732e-06       -0.445944            -inf        0.660766             inf 256604
1.920258e-01 -4.751494e-01       -0.503799        0.660766        1.132690            -inf 213802
6.082213e-07 -5.676732e-06       -0.445944        1.132690        1.189710             inf 256604
1.621924e-06 -1.682746e-05       -0.445934        1.189710        1.272423             inf 256604
1.018163e-03 -1.972097e-02       -0.424491        1.272423        1.519500        0.609048 255218
1.015730e-03 -1.971367e-02       -0.424491        1.519500        1.666821        0.609213 255219
8.048796e-04 -1.902212e-02       -0.424527        1.666821        1.992824        0.626413 255282
8.024467e-04 -1.901239e-02       -0.424528        1.992824        2.190932        0.626704 255283
7.977836e-04 -1.899131e-02       -0.424533        2.190932        2.266754        0.627397 255285
7.558164e-04 -1.879201e-02       -0.424580        2.266754        2.346150        0.634108 255305
7.548027e-04 -1.878694e-02       -0.424581        2.346150        2.628160        0.634283 255306
7.533835e-04 -1.877843e-02       -0.424584        2.628160        2.860128        0.634606 255307
7.517616e-04 -1.876707e-02       -0.424588        2.860128        3.056700        0.635065 255308
7.489232e-04 -1.874437e-02       -0.424597        3.056700        3.210720        0.636025 255309
7.266217e-04 -1.854568e-02       -0.424682        3.210720        3.237954        0.644621 255326
7.043203e-04 -1.834132e-02       -0.424775        3.237954        3.276458        0.866017 255344
7.039148e-04 -1.833726e-02       -0.424778        3.276458        3.653689        0.866024 255345
7.020902e-04 -1.831354e-02       -0.424794        3.653689        3.758065        0.866067 255346
7.012792e-04 -1.830219e-02       -0.424802        3.758065        3.795073        0.866088 255347
6.996573e-04 -1.827888e-02       -0.424818        3.795073        3.854444        0.866131 255349
6.994545e-04 -1.827583e-02       -0.424821        3.854444        3.919027        0.866136 255350
6.980353e-04 -1.825353e-02       -0.424837        3.919027        3.943936        0.866178 255352
6.953997e-04 -1.821136e-02       -0.424867        3.943936        3.978006        0.866258 255353
6.943860e-04 -1.819474e-02       -0.424879        3.978006        4.027451        0.866289 255355
6.937778e-04 -1.818440e-02       -0.424886        4.027451        4.105738        0.866309 255356
6.925614e-04 -1.816250e-02       -0.424902        4.105738        4.179388        0.866351 255357
6.923586e-04 -1.815865e-02       -0.424905        4.179388        4.215226        0.866359 255358
6.114652e-04 -1.657991e-02       -0.426083        4.215226        4.247834        0.869422 255480
6.112624e-04 -1.657586e-02       -0.426086        4.247834        4.261919        0.869430 255481
5.769993e-04 -1.588329e-02       -0.426607        4.261919        4.270425        0.870776 255535
5.403033e-04 -1.513660e-02       -0.427170        4.270425        4.375232        0.872227 255601
5.401005e-04 -1.513214e-02       -0.427173        4.375232        4.400498        0.872235 255602
5.299635e-04 -1.490487e-02       -0.427347        4.400498        4.434580        0.872682 255623
5.293553e-04 -1.489088e-02       -0.427358        4.434580        4.520734        0.872709 255624
2.027404e-07 -2.027404e-06       -0.446036        4.520734        4.691348        2.720473 256604
=new up cost model
    Linear        Log        Constant    min_log_mean    max_log_mean   prev_log_mean data_i
2.027404e-07 -2.027404e-06       -0.445946            -inf        0.560052             inf 256605
6.082213e-07 -5.676732e-06       -0.445944        0.560052        0.560052             inf 256604
6.082213e-07 -5.676732e-06       -0.445944        0.560052        0.660766             inf 256605
1.920258e-01 -4.751494e-01       -0.503799        0.660766        0.660766            -inf 213802
6.082213e-07 -5.676732e-06       -0.445944        0.660766        1.189710             inf 256605
1.621924e-06 -1.682746e-05       -0.445934        1.189710        1.272423             inf 256605
1.018163e-03 -1.972097e-02       -0.424491        1.272423        1.519500        0.609048 255218
1.015730e-03 -1.971367e-02       -0.424491        1.519500        1.666821        0.609213 255219
8.048796e-04 -1.902212e-02       -0.424527        1.666821        1.992824        0.626413 255282
8.024467e-04 -1.901239e-02       -0.424528        1.992824        2.190932        0.626704 255283
7.977836e-04 -1.899131e-02       -0.424533        2.190932        2.266754        0.627397 255285
7.558164e-04 -1.879201e-02       -0.424580        2.266754        2.346150        0.634108 255305
7.548027e-04 -1.878694e-02       -0.424581        2.346150        2.628160        0.634283 255306
7.533835e-04 -1.877843e-02       -0.424584        2.628160        2.860128        0.634606 255307
7.517616e-04 -1.876707e-02       -0.424588        2.860128        3.056700        0.635065 255308
7.489232e-04 -1.874437e-02       -0.424597        3.056700        3.210720        0.636025 255309
7.266217e-04 -1.854568e-02       -0.424682        3.210720        3.237954        0.644621 255326
7.043203e-04 -1.834132e-02       -0.424775        3.237954        3.276458        0.866017 255344
7.039148e-04 -1.833726e-02       -0.424778        3.276458        3.653689        0.866024 255345
7.020902e-04 -1.831354e-02       -0.424794        3.653689        3.758065        0.866067 255346
7.012792e-04 -1.830219e-02       -0.424802        3.758065        3.795073        0.866088 255347
6.996573e-04 -1.827888e-02       -0.424818        3.795073        3.854444        0.866131 255349
6.994545e-04 -1.827583e-02       -0.424821        3.854444        3.919027        0.866136 255350
6.980353e-04 -1.825353e-02       -0.424837        3.919027        3.943936        0.866178 255352
6.953997e-04 -1.821136e-02       -0.424867        3.943936        3.978006        0.866258 255353
6.943860e-04 -1.819474e-02       -0.424879        3.978006        4.027451        0.866289 255355
6.937778e-04 -1.818440e-02       -0.424886        4.027451        4.105738        0.866309 255356
6.925614e-04 -1.816250e-02       -0.424902        4.105738        4.179388        0.866351 255357
6.923586e-04 -1.815865e-02       -0.424905        4.179388        4.215226        0.866359 255358
6.114652e-04 -1.657991e-02       -0.426083        4.215226        4.247834        0.869422 255480
6.112624e-04 -1.657586e-02       -0.426086        4.247834        4.261919        0.869430 255481
5.769993e-04 -1.588329e-02       -0.426607        4.261919        4.270425        0.870776 255535
5.403033e-04 -1.513660e-02       -0.427170        4.270425        4.375232        0.872227 255601
5.401005e-04 -1.513214e-02       -0.427173        4.375232        4.400498        0.872235 255602
5.299635e-04 -1.490487e-02       -0.427347        4.400498        4.434580        0.872682 255623
5.293553e-04 -1.489088e-02       -0.427358        4.434580        4.520381        0.872709 255624
0.000000e+00 0.000000e+00       -0.446038        4.520381        4.691348        2.718349 256605
")
##prev(1.210214)=-0.795079
##min(1.210214)=-0.794897
fun.names <- unique(paste(C153.370$funs$fun))
fun.alpha <- rep(1, length(fun.names))
names(fun.alpha) <- fun.names
fun.alpha[grepl("new", fun.names)] <- 0.5
fun.size <- rep(1, length(fun.names))
names(fun.size) <- fun.names
fun.size[grepl("new", fun.names)] <- 2
ggplot()+
  ##coord_cartesian(xlim=c(-1, 1), ylim=c(-20900, -20897.5))+
  geom_vline(aes(xintercept=min_log_mean, color=fun),
             data=C153.370$vlines)+
  scale_size_manual(values=fun.size)+
  scale_alpha_manual(values=fun.alpha)+
  geom_line(aes(log.mean, cost, color=fun, size=fun, alpha=fun),
            data=C153.370$funs)

ggplot()+
  coord_cartesian(xlim=c(0, 2), ylim=c(-0.446, -0.4459))+
  geom_vline(xintercept=0.925238)+
  geom_vline(aes(xintercept=min_log_mean, color=fun),
             data=C153.370$vlines)+
  scale_size_manual(values=fun.size)+
  scale_alpha_manual(values=fun.alpha)+
  geom_line(aes(log.mean, cost, color=fun, size=fun, alpha=fun),
            data=C153.370$funs)

C153.370 <- gdata("
=prev down cost
    Linear        Log        Constant    min_log_mean    max_log_mean   prev_log_mean data_i
7.71612876675685873838e-06 -1.08025802734596022337e-04 -1.60143610896850252523e+00            -inf        2.340535        2.340535 19491
2.80352678525499121771e-04 -2.93984506013436229163e-03 -1.59763995601961883430e+00        2.340535        2.350271             inf 19491
2.80352678525499121771e-04 -2.93984506013436229163e-03 -1.59763995601961883430e+00        2.350271        2.350271             inf 19490
7.71612876675685873838e-06 -1.08025802734596022337e-04 -1.60143597433024820198e+00        2.350271        2.370340        2.370340 19491
2.57204292225228687858e-04 -2.77780635603246941687e-03 -1.59777746701931677720e+00        2.370340        2.387384             inf 19491
7.71612876675685873838e-06 -1.08025802734596022337e-04 -1.60143558434297017534e+00        2.387384        2.455592        2.455592 19491
2.00619347935678340750e-04 -2.35599131678309410207e-03 -1.59816346313521062683e+00        2.455592        2.491334             inf 19491
1.95475262091173682425e-04 -2.31483863002705791967e-03 -1.59820386116034351964e+00        2.491334        2.674246             inf 19491
1.67182789946398617292e-04 -2.03448595150155847264e-03 -1.59854331236096625091e+00        2.674246        2.720892             inf 19491
1.59466661179641805987e-04 -1.94960853506723316882e-03 -1.59865701679626703857e+00        2.720892        2.731043             inf 19491
2.57204292225228647200e-05 -3.42081708659554100099e-04 -1.60099438569661134402e+00        2.731043        3.871201             inf 19491
=min less(prev down cost)
    Linear        Log        Constant    min_log_mean    max_log_mean   prev_log_mean data_i
7.71612876675685873838e-06 -1.08025802734596022337e-04 -1.60143610896850252523e+00            -inf        2.340535             inf 19491
2.80352678525499121771e-04 -2.93984506013436229163e-03 -1.59763995601961883430e+00        2.340535        2.350271             inf 19491
0.00000000000000000000e+00 0.00000000000000000000e+00 -1.60160893429583706116e+00        2.350271        3.871201        2.350271 19490
")
fun.names <- unique(paste(C153.370$funs$fun))
fun.alpha <- rep(1, length(fun.names))
names(fun.alpha) <- fun.names
fun.alpha[grepl("min", fun.names)] <- 0.5
fun.size <- rep(1, length(fun.names))
names(fun.size) <- fun.names
fun.size[grepl("min", fun.names)] <- 2
ggplot()+
  scale_size_manual(values=fun.size)+
  geom_vline(xintercept=2.421488)+
  scale_alpha_manual(values=fun.alpha)+
  geom_line(aes(log.mean, cost, color=fun, size=fun, alpha=fun),
            data=C153.370$funs)

ggplot()+
  coord_cartesian(xlim=c(2.25, 2.5), ylim=c(-1.60161, -1.601605))+
  geom_vline(xintercept=2.421488)+
  geom_vline(aes(xintercept=min_log_mean, color=fun),
             data=C153.370$vlines)+
  scale_size_manual(values=fun.size)+
  scale_alpha_manual(values=fun.alpha)+
  geom_line(aes(log.mean, cost, color=fun, size=fun, alpha=fun),
            data=C153.370$funs)


C19492 <- gdata("
=prev up cost
    Linear        Log        Constant    min_log_mean    max_log_mean   prev_log_mean data_i
4.91808487021026400553e-07 -2.26231904029672152725e-06 -7.23450631660174758863e-01            -inf       -1.008202             inf 615174
6.47219968919670934557e-05 -9.07878467040814914144e-05 -7.23563319251670611365e-01       -1.008202       -0.577765             inf 615174
3.73774450135980183005e-05 -7.54434219090254599245e-05 -7.23539109353650400358e-01       -0.577765        0.092634       -0.577765 615162
2.50571506052340506332e-02 -5.76253971476481108294e-02 -7.45656217908019391949e-01        0.092634        0.126624            -inf 604113
2.52340049371668519174e-02 -5.80815003385117406554e-02 -7.45799192288678969298e-01        0.126624        0.143710       -0.158941 604020
2.52284966821122585978e-02 -5.80759920834567552883e-02 -7.45793624328279780578e-01        0.143710        0.365503       -0.143351 604021
3.02044182303962543967e-02 -7.25326041977417818041e-02 -7.47681183079121680635e-01        0.365503        0.441952       -0.597577 601339
3.01961558478142828854e-02 -7.25243418151604174460e-02 -7.47671980528250679221e-01        0.441952        0.810961       -0.450337 601340
2.66006423609008134379e-02 -6.50814105342817222910e-02 -7.45617753245932823880e-01        0.810961        0.858767        0.719571 602792
1.68104075331681514227e-02 -4.30257671253368514930e-02 -7.41451023068303904928e-01        0.858767        0.895418        0.787915 606970
1.54779016184334681366e-02 -3.99285539974732622825e-02 -7.40961870606795081073e-01        0.895418        0.898212        0.793055 607572
7.75463949995272485566e-03 -2.18283295262438094275e-02 -7.38257484435179467397e-01        0.898212        0.898249        0.813583 611015
3.66776015365666910317e-02 -1.10980126117399907626e-01 -7.29191530976320834156e-01        0.898249        1.078507        0.732563 594906
3.65173703314953801424e-02 -1.10581466157821189933e-01 -7.29150362899398829519e-01        1.078507        1.102243        0.736673 594984
6.05742218188077607977e-01 -2.01913321901739895026e+00 -3.39348425314019208621e-01        1.102243        1.160130        0.692628 249877
4.47832742622164325930e-01 -1.55331474493974219797e+00 -3.75972238217859633380e-01        1.160130        1.299985        1.064374 335066
1.71259518584403719332e-01 -6.22664069524393015698e-01 -5.70990185034597641511e-01        1.299985        1.319299        1.159859 503623
6.29543388279156096443e-02 -2.46491364482315761242e-01 -6.62126638938351552710e-01        1.319299        1.532028        1.177167 571353
4.91808487021026400553e-07 -2.26231904029672152725e-06 -7.48432664836459538016e-01        1.532028        1.563389        1.198091 615173
2.95085092212615872095e-07 -1.47542546106307941342e-06 -7.48432955707623248642e-01        1.563389        4.189655        1.198091 615174
=min more(prev up cost)
    Linear        Log        Constant    min_log_mean    max_log_mean   prev_log_mean data_i
0.00000000000000000000e+00 0.00000000000000000000e+00 -7.48433854887836202963e-01            -inf        1.609438        1.609438 615174
2.95085092212615872095e-07 -1.47542546106307941342e-06 -7.48432955707623248642e-01        1.609438        4.189655             inf 615174
")
fun.names <- unique(paste(C19492$funs$fun))
fun.alpha <- rep(1, length(fun.names))
names(fun.alpha) <- fun.names
fun.alpha[grepl("min", fun.names)] <- 0.5
fun.size <- rep(1, length(fun.names))
names(fun.size) <- fun.names
fun.size[grepl("min", fun.names)] <- 2
ggplot()+
  scale_size_manual(values=fun.size)+
  geom_vline(xintercept=1.230057)+
  scale_alpha_manual(values=fun.alpha)+
  geom_line(aes(log.mean, cost, color=fun, size=fun, alpha=fun),
            data=C19492$funs)

ggplot()+
  coord_cartesian(xlim=c(1, 1.6), ylim=c(-0.7550, -0.748))+
  geom_vline(xintercept=1.230057)+
  geom_vline(aes(xintercept=min_log_mean, color=fun),
             data=C19492$vlines)+
  scale_size_manual(values=fun.size)+
  scale_alpha_manual(values=fun.alpha)+
  geom_line(aes(log.mean, cost, color=fun, size=fun, alpha=fun),
            data=C19492$funs)

C3down <- gdata("
=prev up cost
    Linear        Log        Constant    min_log_mean    max_log_mean   prev_log_mean data_i
5.40909090909090934929e+01 -1.07919191919191931106e+02 1.51515151515151536010e+00            -inf        0.693147             inf 0
=min more(prev up cost)
    Linear        Log        Constant    min_log_mean    max_log_mean   prev_log_mean data_i
0.00000000000000000000e+00 0.00000000000000000000e+00 3.48927670508883096545e+01            -inf        0.690717        0.690717 0
5.40909090909090934929e+01 -1.07919191919191931106e+02 1.51515151515151536010e+00        0.690717        0.693147             inf 0
")
fun.names <- unique(paste(C3down$funs$fun))
fun.alpha <- rep(1, length(fun.names))
names(fun.alpha) <- fun.names
fun.alpha[grepl("min", fun.names)] <- 0.5
fun.size <- rep(1, length(fun.names))
names(fun.size) <- fun.names
fun.size[grepl("min", fun.names)] <- 2
ggplot()+
  scale_size_manual(values=fun.size)+
  scale_alpha_manual(values=fun.alpha)+
  geom_line(aes(log.mean, cost, color=fun, size=fun, alpha=fun),
            data=C3down$funs)

ggplot()+
  coord_cartesian(xlim=c(0.67, 0.7), ylim=c(34.8925,34.9))+
  geom_vline(aes(xintercept=min_log_mean, color=fun),
             data=C3down$vlines)+
  scale_size_manual(values=fun.size)+
  scale_alpha_manual(values=fun.alpha)+
  geom_line(aes(log.mean, cost, color=fun, size=fun, alpha=fun),
            data=C3down$funs)



C3down <- gdata("
=min more(prev up cost)
    Linear        Log        Constant    min_log_mean    max_log_mean   prev_log_mean data_i
0.00000000000000000000e+00 0.00000000000000000000e+00 3.48927670508883096545e+01            -inf        0.690717        0.690717 1
5.40909090909090934929e+01 -1.07919191919191931106e+02 1.51515151515151536010e+00        0.690717        0.693147             inf 1
=prev down cost
    Linear        Log        Constant    min_log_mean    max_log_mean   prev_log_mean data_i
1.00000000000000000000e+00 -1.73737373737373745897e+00 0.00000000000000000000e+00            -inf        0.693147        0.000000 -1
=new down cost model
    Linear        Log        Constant    min_log_mean    max_log_mean   prev_log_mean data_i
0.00000000000000000000e+00 0.00000000000000000000e+00 3.48927670508883096545e+01            -inf      -20.083628        0.690717 1
1.00000000000000000000e+00 -1.73737373737373745897e+00 0.00000000000000000000e+00      -20.083628        0.693147        0.000000 -1
")
fun.names <- unique(paste(C3down$funs$fun))
fun.alpha <- rep(1, length(fun.names))
names(fun.alpha) <- fun.names
fun.alpha[grepl("new", fun.names)] <- 0.5
fun.size <- rep(1, length(fun.names))
names(fun.size) <- fun.names
fun.size[grepl("new", fun.names)] <- 2
ggplot()+
  scale_size_manual(values=fun.size)+
  scale_alpha_manual(values=fun.alpha)+
  geom_line(aes(log.mean, cost, color=fun, size=fun, alpha=fun),
            data=C3down$funs)

ggplot()+
  coord_cartesian(xlim=c(0.67, 0.7), ylim=c(34.8925,34.9))+
  geom_vline(aes(xintercept=min_log_mean, color=fun),
             data=C3down$vlines)+
  scale_size_manual(values=fun.size)+
  scale_alpha_manual(values=fun.alpha)+
  geom_line(aes(log.mean, cost, color=fun, size=fun, alpha=fun),
            data=C3down$funs)

