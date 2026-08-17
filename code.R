library(readxl)
library(survival)

dados_sens_raw <- read_excel("terra (2).xlsx")

itens_problematicos <- list(
  P1_liberdade = c(14),
  P2_seguranca = c(14, 15, 17, 18, 20, 21),
  P3_autopreservacao = c(7, 14, 19)
)

reconstroi_trial_sensibilidade <- function(x) {
  
  x <- x[order(x$t), ]
  persona_atual <- as.character(x$persona[1])
  
  x$problematico <- x$numero_pergunta %in%
    itens_problematicos[[persona_atual]]
  
  falha_problematico <- which(x$problematico & x$resultado == 0)
  
  if (length(falha_problematico) > 0) {
    
    indice_falha <- falha_problematico[1]
    
    x_antes_falha <- x[seq_len(indice_falha - 1), ]
    x_mantido <- x_antes_falha[!x_antes_falha$problematico, ]
    
    tempo_sens <- nrow(x_mantido)
    evento_sens <- 0   
    
  } else {
    
    x_mantido <- x[!x$problematico, ]
    
    tempo_sens <- nrow(x_mantido)
    
    evento_sens <- as.integer(tail(x_mantido$resultado, 1) == 0)
  }
  
  data.frame(
    modelo = x$modelo[1],
    persona = persona_atual,
    numero_replica = x$numero_replica[1],
    tempo_sens = tempo_sens,
    evento_sens = evento_sens
  )
}

lista_trials <- split(
  dados_sens_raw,
  interaction(
    dados_sens_raw$modelo,
    dados_sens_raw$persona,
    dados_sens_raw$numero_replica,
    drop = TRUE
  )
)

trials_sens <- do.call(
  rbind,
  lapply(lista_trials, reconstroi_trial_sensibilidade)
)

trials_sens <- trials_sens[
  order(trials_sens$persona, trials_sens$numero_replica),
]

print(trials_sens)

resumo_sens <- aggregate(
  cbind(evento_sens, tempo_sens) ~ persona,
  data = trials_sens,
  FUN = sum
)

n_trials_sens <- aggregate(
  numero_replica ~ persona,
  data = trials_sens,
  FUN = length
)

resumo_sens <- merge(resumo_sens, n_trials_sens, by = "persona")
names(resumo_sens) <- c(
  "Persona",
  "Failures",
  "Total_time",
  "Trials"
)

resumo_sens$Censored <- resumo_sens$Trials - resumo_sens$Failures
resumo_sens$Mean_observed_time <- resumo_sens$Total_time / resumo_sens$Trials

print(resumo_sens)

ekm_sens <- survfit(
  Surv(tempo_sens, evento_sens) ~ persona,
  data = trials_sens
)

logrank_sens <- survdiff(
  Surv(tempo_sens, evento_sens) ~ persona,
  data = trials_sens
)

p_sens <- pchisq(
  logrank_sens$chisq,
  df = length(logrank_sens$n) - 1,
  lower.tail = FALSE
)

print(logrank_sens)
cat(
  "\nSensitivity log-rank test:",
  "Chi-square =", round(logrank_sens$chisq, 2),
  "| df =", length(logrank_sens$n) - 1,
  "| p =", round(p_sens, 4),
  "\n"
)

par(mfrow = c(1, 3))

plot(
  ekm_sens[1],
  conf.int = TRUE,
  mark.time = TRUE,
  xlab = "Time (non-flagged challenge questions)",
  ylab = "Estimated survival probability, S(t)",
  main = "P1: Individual freedom",
  font.lab = 2,
  font.axis = 2,
  font.main = 2
)

plot(
  ekm_sens[2],
  conf.int = TRUE,
  mark.time = TRUE,
  xlab = "Time (non-flagged challenge questions)",
  ylab = "Estimated survival probability, S(t)",
  main = "P2: Safety/protection",
  font.lab = 2,
  font.axis = 2,
  font.main = 2
)

plot(
  ekm_sens[3],
  conf.int = TRUE,
  mark.time = TRUE,
  xlab = "Time (non-flagged challenge questions)",
  ylab = "Estimated survival probability, S(t)",
  main = "P3: Self-preservation",
  font.lab = 2,
  font.axis = 2,
  font.main = 2
)

par(mfrow = c(1, 1))