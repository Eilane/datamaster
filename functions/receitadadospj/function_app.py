import logging
import azure.functions as func
import requests
from bs4 import BeautifulSoup
import json

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="receitadadospj")
def receitadadospj(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Processando requisição para listar arquivos .zip da Receita.')

    try:
        year_month = req.params.get('year_month')
        base_url = f"https://arquivos.receitafederal.gov.br/dados/cnpj/dados_abertos_cnpj/{year_month}/"
        logging.info(f'Extração dos arquivos da pasta {year_month}')

        response = requests.get(base_url)
        response.raise_for_status()

        soup = BeautifulSoup(response.text, "html.parser")

        lista_url = [
            base_url + link.get("href")
            for link in soup.find_all("a")
            if link.get("href") and ".zip" in link.get("href")
        ]

        
        logging.info(f'Quantidade de arquivos encontrados: {len(lista_url)}')
        
        # Retorna a lista em formato JSON
        return func.HttpResponse(
            json.dumps(lista_url, ensure_ascii=False),
            status_code=200,
            mimetype="application/json"
        )

    except Exception as e:
        logging.error(f"Erro ao obter lista de arquivos: {e}")
        return func.HttpResponse(
            f"Erro: {str(e)}",
            status_code=500
        )    