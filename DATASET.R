## code to prepare `DATASET` dataset goes here
install.packages(c("renv", "dplyr"))

pacotes <- renv::dependencies() |>
  dplyr::filter(!Package %in% c("renv", "dplyr")) |>
  dplyr::pull(Package) |>
  unique()

install.packages(pacotes)

library(janitor)
library(dplyr)
library(readr)
library(echarts4r)
library(htmltools)


# ingressos <- read_delim("X:/PEP/PEP_reload/PEP_qvd_InOutrasFontes/Fontes_CSV/Infograficos/ingressos.csv",
#                         delim = ";", escape_double = FALSE, trim_ws = TRUE)
# 
# df_ingressos <-  ingressos |>
#   filter(`Tipo de Ingresso (Ingresso)` == "Concurso",
#          `Sem GDF (Ingresso)` == "Sim"
#          ) |>
#   group_by(`Ano Ingresso`) |>
#   summarise(
#     Ingressos = sum(`#qtd_ingresso` )
#   )
# 
# df <- vroom::vroom("X:/PEP/PEP_reload/PEP_qvd_InOutrasFontes/Fontes_CSV/Infograficos/aposentadorias.csv")
# #glimpse(df_aposent)
# 
# df_aposent <- df |>
#   filter(`Sem GDF (Aposentadoria)` == "Sim") |>
#   group_by(`Ano Aposentadoria`) |>
#   summarise(
#     Total = sum(`#QtdAposentadoria`)
#   )
# 
# df <- vroom::vroom("X:/PEP/PEP_reload/PEP_qvd_InOutrasFontes/Fontes_CSV/Infograficos/desligamentos.csv")
# #glimpse(df_deslig)
# 
# df_deslig <- df |>
#   #filter(`Sem GDF (Aposentadoria)` == "Sim") |>
#   group_by(`Desligamentos (ano de exclusão)`) |>
#   summarise(
#     Total = sum(`Desligamentos (servidores)`)
#   )
# 
# df_saida <-  df_deslig |>
#   dplyr::left_join(df_aposent,
#                    by = c("Desligamentos (ano de exclusão)" = "Ano Aposentadoria")) |>
#       dplyr::mutate(
#         Saidas = Total.x + Total.y
#       )
# 
# data <- df_ingressos |>
#   left_join(df_saida,
#             by = c("Ano Ingresso" = "Desligamentos (ano de exclusão)")) |>
#   filter(`Ano Ingresso` >= 2012) |>
#   rename( Ano = `Ano Ingresso`) |>
#   mutate(Reposicao = Ingressos/Saidas) |>
#   select(-Total.x, -Total.y)


#readr::write_csv2(data, "data-raw/taxa.csv")


data <- readr::read_csv2("data-raw/taxa.csv", locale = readr::locale(decimal_mark = ",", grouping_mark = ".")) |> 
  janitor::clean_names() |> 
  dplyr::mutate(Taxa = round((ingressos/saidas), digits =  2), 
                ano = as.factor(ano),
                saidas = saidas * -1) 


library(echarts4r)

formatar_numero_br <- function(serie) {
  htmlwidgets::JS(
    glue::glue(
      "function(params) {return Intl.NumberFormat('pt-BR', { style: 'decimal'}).format(params.value[{{serie}}]);}",
      .open = "{{",
      .close = "}}"
    )
  )
} 


e1 <- data |> 
  e_charts(
    ano,
    height = 195,
    elementId = "chart1" # specify id
  ) |> 
  e_bar(ingressos, name = "Ingressos", stack = "grp") |> 
  e_bar(saidas, name = "Saídas", stack = "grp") |>  
  #e_datazoom(show = FALSE) |>  # hide
  echarts4r::e_legend(right = 0) |>
  e_format_y_axis(
    suffix = "",
    prefix = "",
    formatter = e_axis_formatter(locale = "PT", digits = 0)
  )|>
  echarts4r::e_theme_custom('{"color":["#004580","#ef0219"]}') |>  # theme
  echarts4r::e_tooltip(trigger = "axis")


e2 <- data |> 
  e_charts(
    ano,
    height = 185
  ) |> 
  e_line(Taxa) |> 
  e_y_axis(formatter = e_axis_formatter(style = "percent", digits = 0)) |> 
  #e_datazoom() |>
  echarts4r::e_title("Taxa de Reposição", "Poder Executivo Federal") |>
  echarts4r::e_legend(right = 0) |>
  echarts4r::e_theme_custom('{"color":["#004580","#ef0219"]}') |>  # theme
  echarts4r::e_tooltip(
    formatter = htmlwidgets::JS("function(params){
                                return(
                                'Ano: ' + params.value[0] + 
                                '<br />Taxa: '+params.value[1]*100 + '%')}")
  ) 
#e_locale("PT-br") |>


# Seus códigos para criar os gráficos e1 e e2

# Crie um layout HTML personalizado
# layout <- tagList(
#   tags$div(
#     e2
#   ),
#   tags$div(
#     e1
#   )
# )

# data_hora <- function() {
#   paste("Data e Hora Atual: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
# }

# Seus códigos para criar os gráficos e1 e e2

# Crie um layout HTML personalizado com gráficos um abaixo do outro e a data/hora atual
layout <- tagList(
  tags$div(
    #HTML(data_hora()),  # Adicione a função para mostrar a data e hora atual
    e2
  ),
  tags$div(
    e1
  )
)


# Salve o layout HTML com os gráficos
save_html(
  layout,
  file = "docs/index.html"
)

