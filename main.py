import os

import autorag
import click
from autorag.evaluator import Evaluator
from dotenv import load_dotenv
# from llama_index.embeddings.cohere import CohereEmbedding
from llama_index.embeddings.huggingface import HuggingFaceEmbedding
# from llama_index.embeddings.upstage import UpstageEmbedding
from llama_index.embeddings.bedrock import BedrockEmbedding
from llama_index.embeddings.gemini import GeminiEmbedding

root_path = os.path.dirname(os.path.realpath(__file__))
data_path = os.path.join(root_path, 'data')

@click.command()
@click.option('--config', type=click.Path(exists=True), default=os.path.join(root_path, 'config',
                                                                             'embedding_benchmark.yaml'))
@click.option('--qa_data_path', type=click.Path(exists=True), default=os.path.join(data_path, 'qa_v4.parquet'))
@click.option('--corpus_data_path', type=click.Path(exists=True),
              default=os.path.join(data_path, 'ocr_corpus_v3.parquet'))
@click.option('--project_dir', type=click.Path(exists=False), default=os.path.join(root_path, 'benchmark'))
def main(config, qa_data_path, corpus_data_path, project_dir):
    load_dotenv()

    # autorag.embedding_models = {}
    autorag.embedding_models['mxbai-embed-large-v1'] = autorag.LazyInit(HuggingFaceEmbedding, model_name="mixedbread-ai/mxbai-embed-large-v1")
    autorag.embedding_models['bge-m3'] = autorag.LazyInit(HuggingFaceEmbedding, model_name="BAAI/bge-m3")
    autorag.embedding_models['qwen3-embedding-0.6b'] = autorag.LazyInit(HuggingFaceEmbedding, model_name="Qwen/Qwen3-Embedding-0.6B")
    autorag.embedding_models['inf-retriever-v1-1.5b'] = autorag.LazyInit(HuggingFaceEmbedding, model_name="infly/inf-retriever-v1-1.5b")
    autorag.embedding_models['gte-qwen2-1.5b-instruct'] = autorag.LazyInit(HuggingFaceEmbedding, model_name="Alibaba-NLP/gte-Qwen2-1.5B-instruct")
    autorag.embedding_models['amazon-titan-embed-text-v2'] = autorag.LazyInit(BedrockEmbedding,
                                                                             model_name="amazon.titan-embed-text-v2:0",
                                                                             aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'),
                                                                             aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY'),
                                                                             region_name=os.getenv('AWS_REGION'),
                                                                             )
    autorag.embedding_models['cohere-embed-multilingual-v3'] = autorag.LazyInit(BedrockEmbedding,
                                                                             model_name="cohere.embed-multilingual-v3",
                                                                             aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'),
                                                                             aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY'),
                                                                             region_name=os.getenv('AWS_REGION'),
                                                                             )
    autorag.embedding_models['gemini-text-embedding-004'] = autorag.LazyInit(GeminiEmbedding,
                                                                        model_name='models/text-embedding-004',
                                                                        api_key=os.getenv('GEMINI_API_KEY'))

    autorag.embedding_models.pop('openai')
    autorag.embedding_models.pop('openai_embed_3_small')
    autorag.embedding_models.pop('huggingface_baai_bge_small')
    autorag.embedding_models.pop('huggingface_cointegrated_rubert_tiny2')
    autorag.embedding_models.pop('huggingface_all_mpnet_base_v2')

    print(autorag.embedding_models)

    if not os.path.exists(project_dir):
        os.makedirs(project_dir)
    evaluator = Evaluator(qa_data_path, corpus_data_path, project_dir=project_dir)
    evaluator.start_trial(config)


if __name__ == '__main__':
    main()
