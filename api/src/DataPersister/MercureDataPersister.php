<?php

namespace App\DataPersister;

use ApiPlatform\Core\Api\IriConverterInterface;
use ApiPlatform\Core\Api\UrlGeneratorInterface;
use ApiPlatform\Core\DataPersister\ContextAwareDataPersisterInterface;
use ApiPlatform\Core\DataProvider\SerializerAwareDataProviderTrait;
use ApiPlatform\Core\Metadata\Resource\Factory\ResourceMetadataFactoryInterface;
use ApiPlatform\Core\Util\ClassInfoTrait;
use App\Entity\ChatMessage;
use Symfony\Component\Mercure\PublisherInterface;
use Symfony\Component\Mercure\Update;
use Symfony\Component\Messenger\MessageBusInterface;
use Symfony\Component\Serializer\Normalizer\AbstractNormalizer;
use Symfony\Component\Serializer\SerializerInterface;

class MercureDataPersister implements ContextAwareDataPersisterInterface
{
    use ClassInfoTrait;

    private $decorated;
    private $publisher;
    private $iriConverter;
    private $serializer;
    private $resourceMetadataFactory;
    private $bus;

    public function __construct(ContextAwareDataPersisterInterface $decoratedDataPersister, MessageBusInterface $bus, PublisherInterface $publisher, IriConverterInterface $iriConverter, SerializerInterface $serializer, ResourceMetadataFactoryInterface $resourceMetadataFactory)
    {
        $this->bus = $bus;
        $this->decorated = $decoratedDataPersister;
        $this->publisher = $publisher;
        $this->iriConverter = $iriConverter;
        $this->serializer = $serializer;
        $this->resourceMetadataFactory = $resourceMetadataFactory;
    }

    public function supports($data, array $context = []): bool
    {
        return $this->decorated->supports($data, $context);
    }

    public function persist($data, array $context = [])
    {
        $result = $this->decorated->persist($data, $context);

        if ($data instanceof ChatMessage && (
            ($context['collection_operation_name'] ?? null) === 'post' ||
            ($context['graphql_operation_name'] ?? null) === 'create'
            )
        ) {
            $metas = $this->resourceMetadataFactory->create($this->getObjectClass($data));
            $context = $metas->getCollectionOperationAttribute('post', 'normalization_context', [], true);
            $iri = 'http://example.com' . $this->iriConverter->getIriFromItem($data->getRoom(), UrlGeneratorInterface::ABS_PATH);

            $payload = $this->serializer->serialize([
                "type" => "new-message",
                "data" => $data
            ], 'json', $context);
            $update = new Update($iri, $payload, true, null, 'new-message', null);
            $this->bus->dispatch($update);

            if ($data->getRoom()->isPrivate() || $data->getRoom()->getApplication()) {
                foreach($data->getRoom()->getUsers() as $user) {
                    $iri = 'http://example.com' . $this->iriConverter->getIriFromItem($user, UrlGeneratorInterface::ABS_PATH);
                    $update = new Update($iri, $payload, true, null, 'new-message', null);
                    $this->bus->dispatch($update);
                }
            }
        }

        return $result;
    }

    public function remove($data, array $context = [])
    {
        return $this->decorated->remove($data, $context);
    }
}