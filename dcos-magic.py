    import json
    import matplotlib.pyplot as plt
    import os
    import pandas as pd
    import requests

def dcos(option):
    dcos_url = os.popen('dcos config show core.dcos_url').read().rstrip()
    dcos_token = os.popen('dcos config show core.dcos_acs_token').read().rstrip()
    dcos_cert = os.popen('dcos config show core.ssl_verify').read().rstrip()
    headers = {'Authorization': 'token=' + dcos_token}
    r = requests.get(dcos_url + '/dcos-history-service/history/last', headers=headers, verify=dcos_cert)
    obj = json.loads(r.text)

    dict = {}
    for agent in obj["slaves"]:
        if agent["hostname"] not in dict:
            dict[agent["hostname"]] = {}
        dict[agent["hostname"]]["region"] = agent["domain"]["fault_domain"]["region"]["name"]
        dict[agent["hostname"]]["zone"] = agent["domain"]["fault_domain"]["zone"]["name"]
        if "public_ip" in agent["attributes"]:
            dict[agent["hostname"]]["public"] = True
        else:
            dict[agent["hostname"]]["public"] = False
        dict[agent["hostname"]]["active"] = agent["active"]
        dict[agent["hostname"]]["used_cpus"] = agent["used_resources"]["cpus"]
        dict[agent["hostname"]]["used_gpus"] = agent["used_resources"]["gpus"]
        dict[agent["hostname"]]["used_mem"] = agent["used_resources"]["mem"]
        dict[agent["hostname"]]["used_disk"] = agent["used_resources"]["disk"]
        dict[agent["hostname"]]["total_cpus"] = agent["resources"]["cpus"]
        dict[agent["hostname"]]["total_gpus"] = agent["resources"]["gpus"]
        dict[agent["hostname"]]["total_mem"] = agent["resources"]["mem"]
        dict[agent["hostname"]]["total_disk"] = agent["resources"]["disk"]
    if option == "summary":
        used_resources = {}
        used_resources["cpus"] = 0.0
        used_resources["gpus"] = 0.0
        used_resources["mem"] = 0.0
        used_resources["disk"] = 0.0
        total_resources = {}
        total_resources["cpus"] = 0.0
        total_resources["gpus"] = 0.0
        total_resources["mem"] = 0.0
        total_resources["disk"] = 0.0
        for key in dict:
            if dict[key]["public"] is not True and dict[key]["active"]:
                used_resources["cpus"] += dict[key]["used_cpus"]
                used_resources["gpus"] += dict[key]["used_gpus"]
                used_resources["mem"] += dict[key]["used_mem"]
                used_resources["disk"] += dict[key]["used_disk"]
                total_resources["cpus"] += dict[key]["total_cpus"]
                total_resources["gpus"] += dict[key]["total_gpus"]
                total_resources["mem"] += dict[key]["total_mem"]
                total_resources["disk"] += dict[key]["total_disk"]
        percent_resources = {}
        percent_resources["cpus"] = used_resources["cpus"] * 100 / total_resources["cpus"]
        if total_resources["gpus"] > 0:
            percent_resources["gpus"] = used_resources["gpus"] * 100 / total_resources["gpus"]
        else:
            percent_resources["gpus"] = 100.0
        percent_resources["mem"] = used_resources["mem"] * 100 / total_resources["mem"]
        percent_resources["disk"] = used_resources["disk"] * 100 / total_resources["disk"]
        data = pd.DataFrame.from_dict(percent_resources, orient='index')
        data.rename(columns={0: '% resources used on private nodes'}, inplace=True)
        my_plot = data.plot(kind='bar')
        my_plot.set_ylim(0.0, 100.0)
        return my_plot
    elif option == "sparkcanrun":
        spark_cores_max = int(os.environ['SPARK_CONF_CORES_MAX'].split('=')[1])
        spark_executor_cores = int(os.environ['SPARK_CONF_EXECUTOR_CORES'].split('=')[1])
        spark_executor_memory = os.environ['SPARK_CONF_EXECUTOR_MEMORY'].split('=')[1]
        spark_executor_memory = int(spark_executor_memory[:-1])
        matches = 0
        for key in dict:
            if dict[key]["public"] is not True and dict[key]["active"]:
                if dict[key]["total_cpus"] - dict[key]["used_cpus"] - spark_executor_cores > 0 and dict[key]["total_mem"] - dict[key]["used_mem"] - spark_executor_memory > 0:
                    matches += 1
        if matches >= spark_cores_max / spark_executor_cores:
            return True
        else:
            return False
    elif option == "full":
        data = pd.DataFrame.from_dict(dict, orient='index')
        return data
    else:
        return "Usage: %dcos full, summary or sparkcanrun"

def load_ipython_extension(ipython):
    ipython.register_magic_function(dcos, 'line')
