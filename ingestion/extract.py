import requests
import psycopg2
from dotenv import load_dotenv
import os
import time

load_dotenv()

#bloco 1: conexão com a API:
FOGO_EMAIL = os.getenv("EMAIL")
FOGO_SENHA = os.getenv("SENHA")
url_login = 'https://api-service.fogocruzado.org.br/api/v2/auth/login'
url_ocorrencias = 'https://api-service.fogocruzado.org.br/api/v2/occurrences'
url_estados = 'https://api-service.fogocruzado.org.br/api/v2/states'


def auth(FOGO_EMAIL,FOGO_SENHA):
    r = requests.post(url_login,json = {"email":FOGO_EMAIL,"password":FOGO_SENHA})
    bearer_token = r.json()['data']['accessToken']
    return bearer_token

def get_states(token):
    estados = list()
    r = requests.get(url_estados, headers={"Authorization":f"Bearer {token}"})
    for estado in r.json()['data']:
        estados.append(estado['id'])
    return estados

def get_data(token):
    resultado = list()
    estados = get_states(token)
    for estado in estados:
        pagina = 1
        while pagina<10:
            r1 = requests.get(url_ocorrencias, headers={"Authorization": f"Bearer {token}"}, params = {'idState':estado, 'page':pagina})
            print(r1.status_code)
            resultado.extend(r1.json()['data'])
            pagina += 1
            if r1.json()['pageMeta']['hasNextPage'] == False:
                break
            else:
                time.sleep(0.5)
    return resultado



if __name__ == "__main__":
    token = auth(FOGO_EMAIL, FOGO_SENHA)
    # print(get_data(token))
    print (len(get_data(token))) # -> Para validação apenas, sem despejar milhares de json no terminal


# conn = psycopg2.connect("db_name=elommaio user=elommaio")
