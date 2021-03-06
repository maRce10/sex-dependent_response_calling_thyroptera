
library(readxl)


dat <- read_excel("./data/Datos de respuestas_cap2.xlsx")

dat <- as.data.frame(dat)

head(dat)
dat$estado_repr2[dat$estado_repr == 0] <- "Inactivo"
dat$estado_repr2[dat$estado_repr == 1] <- "Activo"

agg_dat <- aggregate(n_llamadas ~ ID + sexo_consulta + sexo_respuesta + estado_repr2, data = dat, FUN = sum)

library(ggplot2)
ggplot(agg_dat, aes(x = sexo_consulta, y = n_llamadas, fill = sexo_respuesta)) +
geom_boxplot() +
theme_classic(base_size = 24) +
facet_wrap(~ estado_repr2)


dat$n_llam_bin <- ifelse(dat$n_llamadas > 0, 1, 0)


agg_dat2 <- aggregate(n_llam_bin ~ ID + sexo_consulta + sexo_respuesta + estado_repr2, data = dat, FUN = sum)

ggplot(agg_dat2, aes(fill = sexo_consulta, y = n_llam_bin, x = sexo_respuesta)) +
  geom_boxplot() +
  theme_classic(base_size = 24) +
  facet_wrap(~ estado_repr2)

table(agg_dat$sexo_consulta, agg_dat$sexo_respuesta)


table(dat$n_llamadas > 0)

library(MCMCglmm)




# define parmeters for MCMCglmm models
itrns <- 10000
burnin <- 1000
thin <- 100

# prior for effect models
pr <- list(B = list(mu = c(0, 0), V = diag(2) * (1 + pi^2/3)), R = list(V = 1, fix = 1))

pr2 <- list(B = list(mu = c(0, 0, 0), V = diag(3) * (1 + pi^2/3)), R = list(V = 1, fix = 1))

# prior for null model
# prior.m2c.5 <- list(B = list(mu = c(0), V = diag(1) * (1 + pi^2/3)), R = list(V = 1, fix = 1))


md1 <- MCMCglmm(n_llam_bin ~ sexo_respuesta - 1, data = dat, family = "categorical", prior = pr, verbose = FALSE, nitt = itrns, start = list(QUASI = FALSE), burnin = burnin, thin = thin)

summary(md1)

md2 <- MCMCglmm(n_llam_bin ~ sexo_respuesta + sexo_consulta - 1, data = dat, family = "categorical", prior = pr2, verbose = FALSE, nitt = itrns, start = list(QUASI = FALSE), burnin = burnin, thin = thin)

summary(md2)


pr3 <- list(B = list(mu = c(0, 0, 0, 0), V = diag(4) * (1 + pi^2/3)), R = list(V = 1, fix = 1))

md3 <- MCMCglmm(n_llam_bin ~ sexo_respuesta * sexo_consulta - 1, data = dat, family = "categorical", prior = pr3, verbose = FALSE, nitt = itrns, start = list(QUASI = FALSE), burnin = burnin, thin = thin)

summary(md3)

# modelo ER activo
md4 <- MCMCglmm(n_llam_bin ~ sexo_respuesta * sexo_consulta - 1, data = dat[dat$estado_repr2 == "Activo", ], family = "categorical", prior = pr3, verbose = FALSE, nitt = itrns, start = list(QUASI = FALSE), burnin = burnin, thin = thin)

summary(md4)

# modelo ER inactivo
md5 <- MCMCglmm(n_llam_bin ~ sexo_respuesta * sexo_consulta - 1, data = dat[dat$estado_repr2 == "Inactivo", ], family = "categorical", prior = pr3, verbose = FALSE, nitt = itrns, start = list(QUASI = FALSE), burnin = burnin, thin = thin)

summary(md5)

pr6 <- list(B = list(mu = rep(0, 8), V = diag(8) * (1 + pi^2/3)), R = list(V = 1, fix = 1))

md6 <- MCMCglmm(n_llam_bin ~ sexo_respuesta:estado_repr2:sexo_consulta  - 1, data = dat, family = "categorical", prior = pr6, verbose = FALSE, nitt = itrns, start = list(QUASI = FALSE), burnin = burnin, thin = thin)

summary(md6)


# mod.fail <- replicate(3, , simplify = FALSE)
