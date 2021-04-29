<?php

declare(strict_types=1);

namespace App\Command;

use Aws\S3\S3Client;
use Aws\S3\S3ClientInterface;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class S3ListerCommand extends Command
{
    protected static $defaultName = 'demo:s3-list';

    /** @var S3ClientInterface */
    private $s3Client;

    /**
     * @param S3Client $s3Client
     */
    public function __construct(S3Client $s3Client)
    {
        $this->s3Client = $s3Client;

        parent::__construct();
    }


    protected function configure(): void
    {
        $this
            ->setDescription('List S3 buckets')
            ->setHelp('This command allows you to list S3 buckets');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $r = $this->s3Client->listBuckets();
        $buckets = $r->get('Buckets') ?? [];

        $output->writeln("Existing buckets:\n");

        foreach ($buckets as $bucket) {
            $output->writeln($bucket['Name'] ?? null);
        }

        return Command::SUCCESS;
    }
}
