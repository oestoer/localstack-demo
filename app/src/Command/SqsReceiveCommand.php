<?php


namespace App\Command;


use Aws\Sqs\SqsClient;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class SqsReceiveCommand extends Command
{
    private const QUEUE_URL = 'http://localstack:4566/000000000000/my-queue';

    protected static $defaultName = 'demo:sqs-receive';

    /** @var SqsClient */
    private $sqsClient;

    /**
     * @param SqsClient $sqsClient
     */
    public function __construct(SqsClient $sqsClient)
    {
        $this->sqsClient = $sqsClient;

        parent::__construct();
    }


    protected function configure(): void
    {
        $this
            ->setDescription('Read a message from an sqs queue')
            ->setHelp('This command allows you to retrieve a message from an sqs queue');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $output->writeln("Checking queue for messages (20 sec max)...\n");

        $r = $this->sqsClient->receiveMessage(
            [
                'AttributeNames' => ['SentTimestamp'],
                'MaxNumberOfMessages' => 1,
                'MessageAttributeNames' => ['All'],
                'QueueUrl' => self::QUEUE_URL,
                'WaitTimeSeconds' => 20,
            ]
        );

        if (!empty($r->get('Messages'))) {
            $body = json_decode($r->get('Messages')[0]['Body'], true, 512, JSON_THROW_ON_ERROR);
            $output->write("\tMessageId: " . $body['MessageId'] . "\n");
            $output->write("\tMessage: " . $body['Message'] . "\n");

            $this->sqsClient->deleteMessage(
                [
                    'QueueUrl' => self::QUEUE_URL, // REQUIRED
                    'ReceiptHandle' => $r->get('Messages')[0]['ReceiptHandle'] // REQUIRED
                ]
            );
        } else {
            $output->writeln("No messages in queue.\n");
        }

        return Command::SUCCESS;
    }
}
