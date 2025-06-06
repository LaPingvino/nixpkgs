{
  lib,
  buildPythonPackage,
  fetchPypi,
  llama-index-core,
  nebula3-python,
  poetry-core,
  pythonOlder,
}:

buildPythonPackage rec {
  pname = "llama-index-graph-stores-nebula";
  version = "0.4.2";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchPypi {
    pname = "llama_index_graph_stores_nebula";
    inherit version;
    hash = "sha256-0CooGtmDz9OAJ+B543eFbrFTzii5iXwmo0dV4c/E/es=";
  };

  build-system = [ poetry-core ];

  dependencies = [
    llama-index-core
    nebula3-python
  ];

  pythonImportsCheck = [ "llama_index.graph_stores.nebula" ];

  meta = with lib; {
    description = "LlamaIndex Graph Store Integration for Nebula";
    homepage = "https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/graph_stores/llama-index-graph-stores-nebula";
    license = licenses.mit;
    maintainers = with maintainers; [ fab ];
  };
}
