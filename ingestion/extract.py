import requests
import psycopg2
from dotenv import load_dotenv
import os

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
    get_states(token)
    for estado in estados:
        r1 = requests.get(url_ocorrencias, headers={"Authorization": f"Bearer {bearer_token}"}, params = {'idState':estado})
        resultado.extend(r1.json()['data'])
    return r1.json()



if __name__ == "__main__":
    token = auth(FOGO_EMAIL, FOGO_SENHA)
    print(get_data(token))



# conn = psycopg2.connect("db_name=elommaio user=elommaio")
