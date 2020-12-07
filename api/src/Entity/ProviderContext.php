<?php

namespace App\Entity;

use App\Repository\ProviderContextRepository;
use App\Utils\Dataset\ProviderContextInterface;
use Doctrine\ORM\Mapping as ORM;

/**
 * @ORM\Entity(repositoryClass=ProviderContextRepository::class)
 */
class ProviderContext implements ProviderContextInterface
{
    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     */
    private $id;

    /**
     * @ORM\Column(type="datetime")
     */
    private $provided_at;

    /**
     * @ORM\Column(type="string", length=30)
     */
    private $provider_key;

    /**
     * @ORM\Column(type="string", length=30)
     */
    private $provider_version;

    /**
     * @var array
     * @ORM\Column(type="json", nullable=true)
     */
    private $metas;

    public function __construct()
    {
        $this->provided_at = new \DateTime();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getProvidedAt(): \DateTimeInterface
    {
        return $this->provided_at;
    }

    public function setProvidedAt(\DateTimeInterface $provided_at): self
    {
        $this->provided_at = $provided_at;

        return $this;
    }

    public function getProviderKey(): string
    {
        return $this->provider_key;
    }

    public function setProviderKey(string $provider_key): self
    {
        $this->provider_key = $provider_key;

        return $this;
    }

    public function getProviderVersion(): string
    {
        return $this->provider_version;
    }

    public function setProviderVersion(string $version): self
    {
        $this->provider_version = $version;

        return $this;
    }

    public function getMetas(): array
    {
        return $this->metas;
    }

    public function setMetas(array $metas): self
    {
        $this->metas = $metas;
        return $this;
    }
}
