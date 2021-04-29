<?php


namespace App\Command;


use Aws\Sns\SnsClient;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class SnsTriggerCommand extends Command
{
    protected static $defaultName = 'demo:sns-trigger';

    /** @var SnsClient */
    private $snsClient;

    /**
     * @param SnsClient $sqsClient
     */
    public function __construct(SnsClient $sqsClient)
    {
        $this->snsClient = $sqsClient;

        parent::__construct();
    }


    protected function configure(): void
    {
        $this
            ->setDescription('Dispatch a message to an sns topic')
            ->setHelp('This command allows you to dispatch a message to an sns topic')
            ->addOption('message', 'm', InputArgument::OPTIONAL, 'the message to send', 'hello');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $r = $this->snsClient->publish(
            [
                'Message' => $input->getOption('message'),
                'TopicArn' => 'arn:aws:sns:us-east-1:000000000000:my-sns'
            ]
        );
        $output->writeln('MessageId: ' . $r->get('MessageId'));

        return Command::SUCCESS;
    }
}
