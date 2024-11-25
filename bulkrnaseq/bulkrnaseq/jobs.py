import concurrent.futures
import logging
class Jobs:
    def __init__(self, **kwargs):
        self.job_set = kwargs.get('job_set')
        self.job_set_complete = False
        self.max_concurrent_local_jobs = kwargs.get('max_concurrent_local_jobs')
        self.local_job_set = None
        self.slurm_job_set = None
        self.slurm_checkstate_waittime = kwargs.get('slurm_checkstate_waittime')
        self.running_seconds = 0
        return

    # def get_incomplete_jobs(self):
    #     job_list = [job for job in self.job_set if not job.work_complete]
    #     return job_list
    
    def run_jobs(self):
        self.local_job_set = [job for job in job_set if job.machine_type == 'local' and not job.work_complete]        
        with concurrent.futures.ProcessPoolExecutor(max_workers=self.max_concurrent_local_jobs) as executor:
            futures = {
                executor.submit(local_job.run_job())
                for task in self.local_job_set
                }
            for fut in concurrent.futures.as_completed(futures):
                fut.result().set_work_is_complete()
        
        self.slurm_job_set = [job for job in job_set if job.machine_type == 'slurm' and not job.work_complete]
        for slurm_job in self.slurm_job_set:
            slurm_job.run_job()

    def wait_jobs_complete(self):
        running_states = [
            'PENDING',
            'REQUEUED',
            'RESIZING',
            'RUNNING',
            'SUSPENDED'
        ]

        complete_states = [
            'COMPLETE',
            'COMPLETED'
        ]

        canceled_states = [
            'CANCELLED',
        ]

        failed_states = [
            'BOOT_FAIL',
            'DEADLINE',
            'END',
            'FAILED',
            'NODE_FAIL',
            'OOM',
            'OUT_OF_MEMORY',
            'PREEMPTED',
            'REVOKED',
            'TIMEOUT',
        ]


        while not self.job_set_complete:
            complete_job_count = 0
            running_job_count = 0
            for job in self.job_set:
                job.set_slurm_job_state()
                if job.get_slurm_job_state() in complete_states:
                    job.set_work_is_complete()
                    complete_job_count += 1
                elif job.get_slurm_job_state() in running_states:
                    running_job_count += 1
                elif job.get_slurm_job_state() in canceled_states:
                    logging.error(f'job {todo_job.job_id} cancelled. Stopping project')
                    sys.exit(1)
                elif job.get_slurm_job_state() in failed_states:
                    job.create_job()
                    job.run_job()
                    running_job_count += 1
            if complete_job_count == len(self.job_set):
                self.job_set_complete = True
            logging.info('current project status')
            logging.info('----------------------')

            logging.info(f'complete samples: {complete_job_count}')
            logging.info(f'running samples: {running_job_count}')
            logging.info(f'time since submission: {self.running_seconds} seconds')
            time.sleep(self.slurm_checkstate_waittime)
            self.running_seconds = self.running_seconds + self.slurm_checkstate_waittime
        
