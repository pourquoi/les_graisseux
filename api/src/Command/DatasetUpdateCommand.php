<?php

namespace App\Command;

use App\Utils\Dataset\DatasetProviderInterface;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Logger\ConsoleLogger;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;

class DatasetUpdateCommand extends Command
{
    protected static $defaultName = 'app:dataset:update';

    /** @var DatasetProviderInterface[]  */
    protected $providers;

    public function __construct(iterable $providers)
    {
        parent::__construct();

        $this->providers = $providers;
    }

    protected function configure()
    {
        $this
            ->setDescription('Update the datasets with given providers')
            ->addOption('provider', null, InputOption::VALUE_REQUIRED | InputOption::VALUE_IS_ARRAY, 'Only use this provider.', [])
        ;
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new SymfonyStyle($input, $output);

        $providers = $this->providers;

        if ($keys = $input->getOption('provider')) {
            $providers = [];
            foreach($this->providers as $provider) {
                if (in_array($provider->getKey(), $keys)) $providers[] = $provider;
            }
        } else {
            $providers = $this->providers;
        }

        foreach($providers as $provider) {
            $io->info('Using ' . $provider->getKey() . ' provider.');
            $provider->update();
        }

        return Command::SUCCESS;
    }
}
