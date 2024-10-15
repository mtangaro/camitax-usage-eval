# camitax-usage-eval

Camitax is run by default with the docker profile, therefore, while nextflow is running (java), tools belonging to camitax are run as Docker containers, thus making it difficult to monitor the resources consumed by the workflow.

Indeed just tracking the resources used by nextflow would lead to ignoring the consumption of RAM and CPU due to containers, heavily underestimating the resources required to run camitax.

In the following, we are using the ``docker stats`` command to montor cpu and RAM exploited by camitax Dockers.

## Strategy




``nextflow run CAMI-challenge/CAMITAX -profile docker --db /path/to/db --i /path/to/input/data --x fa -c /data/CAMITAX/nextflow.config -bg``

the script ``ompute_docker_total_stats.sh`` run the ``docker stats`` command, sum RAM and CPU consumption for each docker running


> [!NOTE]
> For this strategy to work, the only containers running must be those of camitax so as not to distort the measurement


## Usage



