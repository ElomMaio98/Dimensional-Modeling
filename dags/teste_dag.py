import datetime
from airflow.sdk import DAG
from airflow.providers.standard.operators.empty import EmptyOperator
from airflow.providers.standard.operators.python import PythonOperator

def print_maneiro():
    print('esse print é maneiro')

with DAG(
    dag_id = "minha_dag_foda",
    start_date=datetime.datetime(2026,10,16),
    schedule="@daily"
):
    PythonOperator(task_id = 'minha_task_foda',python_callable = print_maneiro)