<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiFilter;
use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use ApiPlatform\Core\Annotation\ApiSubresource;
use App\Repository\VehicleTreeRepository;
use App\Utils\Dataset\DatasetItemInterface;
use App\Utils\Dataset\ProviderContextInterface;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;
use ApiPlatform\Core\Bridge\Doctrine\Orm\Filter\SearchFilter;
use Symfony\Component\HttpFoundation\File\File;
use Symfony\Component\Serializer\Annotation\Groups;
use Vich\UploaderBundle\Mapping\Annotation as Vich;

/**
 * @ApiResource(
 *     shortName="Vehicle",
 *     normalizationContext={"groups"={"read", "vehicle:read", "energy:read"}},
 *     denormalizationContext={"groups"={"write", "vehicle:write", "energy:write"}},
 *     itemOperations={
 *       "get",
 *       "put"={
 *         "method"="PUT",
 *         "normalization_context"={"groups"={"write", "vehicle:write", "translations"}},
 *         "security"="is_granted('ROLE_ADMIN')"
 *       }
 *     },
 *     collectionOperations={
 *       "get",
 *       "post"={
 *           "method"="POST",
 *           "normalization_context"={"groups"={"write", "vehicle:write", "translations"}},
 *           "security_post_denormalize"="is_granted('ROLE_ADMIN')"
 *       }
 *     }
 * )
 * @ApiFilter(SearchFilter::class, properties={"level": "exact", "name": "word_start", "q": "word_start", "energy.id": "exact", "energy.translations.name": "word_start"})
 * @ORM\Entity(repositoryClass=VehicleTreeRepository::class)
 * @Vich\Uploadable
 * @ORM\HasLifecycleCallbacks()
 */
class VehicleTree implements DatasetItemInterface
{
    const LEVEL_BRAND = 'brand';
    const LEVEL_FAMILY = 'family';
    const LEVEL_MODEL = 'model';
    const LEVEL_TYPE = 'type';

    use Traits\TimestampTrait;
    use Traits\PopularityTrait;

    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     * @Groups({"read", "write"})
     * @ApiProperty(writable=false)
     */
    protected $id;

    /**
     * @var string
     * @ORM\Column()
     * @Groups({"read", "write"})
     */
    protected $level;

    /**
     * @var string
     * @ORM\Column(type="string", length=255)
     * @Groups({"read", "write"})
     */
    protected $name;

    /**
     * @var string
     * @ORM\Column(type="text", nullable=true)
     */
    protected $q;

    /**
     * @var Energy
     * @ORM\ManyToOne(targetEntity="Energy", cascade={"persist"})
     * @Groups({"read", "write"})
     */
    protected $energy;

    /**
     * @var \DateTime
     * @ORM\Column(type="date", nullable=true)
     * @Groups({"read", "write"})
     */
    private $release_date;

    /**
     * @ORM\Column(type="string", length=512, nullable=true)
     */
    private $logoPath;

    /**
     * @var VehicleTree
     * @ORM\ManyToOne(targetEntity="VehicleTree", inversedBy="children", cascade={"persist"})
     * @ApiSubresource()
     * @Groups({"vehicle:read", "job:read", "vehicle:write"})
     */
    protected $parent;

    /**
     * @var Collection|VehicleTree[]
     * @ORM\OneToMany(targetEntity="VehicleTree", mappedBy="parent", cascade={"persist", "remove"})
     * @ApiSubresource()
     */
    protected $children;

    /**
     * @var Collection|ProviderContext[]
     * @ORM\ManyToMany(targetEntity="ProviderContext", cascade={"persist"})
     */
    protected $providers;

    /**
     * @var File|null
     *
     * @Vich\UploadableField(mapping="brand", fileNameProperty="logoPath")
     */
    public $logo;

    /**
     * @var string
     * @Groups("read")
     */
    public $logoUrl;

    /**
     * @var string
     * @Groups("read")
     */
    public $logoThumbUrl;

    public function __construct()
    {
        $this->children = new ArrayCollection();
        $this->providers = new ArrayCollection();
    }

    /**
     * @ORM\PrePersist
     */
    public function prePersist()
    {
        $this->q = $this->computeQ();
    }

    /**
     * @ORM\PreUpdate
     */
    public function preUpdate()
    {
        $this->q = $this->computeQ();
    }

    public function computeQ()
    {
        $q = [];
        if ($this->name) $q[] = $this->name;
        if ($this->parent) $q[] = $this->parent->computeQ();
        return join(' ', $q);
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getName(): ?string
    {
        return $this->name;
    }

    public function setName(string $name): self
    {
        $this->name = $name;

        return $this;
    }

    public function getParent(): ?VehicleTree
    {
        return $this->parent;
    }

    public function setParent(?VehicleTree $parent): self
    {
        $this->parent = $parent;
        return $this;
    }

    public function getChildren(): Collection
    {
        return $this->children;
    }

    public function addChild(VehicleTree $child): self
    {
        if( !$this->children->contains($child) ) {
            $this->children->add($child);
        }

        return $this;
    }

    public function removeChild(VehicleTree $child): self
    {
        if( $this->children->contains($child) ) {
            $this->children->remove($child);
        }

        return $this;
    }

    public function getEnergy(): ?Energy
    {
        return $this->energy;
    }

    public function setEnergy(?Energy $energy): self
    {
        $this->energy = $energy;
        return $this;
    }

    public function getReleaseDate(): ?\DateTime
    {
        return $this->release_date;
    }

    public function setReleaseDate(?\DateTime $date): self
    {
        $this->release_date = $date;
        return $this;
    }

    public function getLevel(): string
    {
        return $this->level;
    }

    public function setLevel(string $level): self
    {
        $this->level = $level;
        return $this;
    }

    public function getQ(): ?string
    {
        return $this->q;
    }

    public function setQ(?string $q): self
    {
        $this->q = $q;
        return $this;
    }

    public function getProviderContexts(): ?array
    {
        return $this->providers->toArray();
    }

    public function getProviderContext(string $key): ?ProviderContextInterface
    {
        foreach($this->providers as $provider) {
            if ($provider->getProviderKey() === $key) return $provider;
        }
        return null;
    }

    public function addProviderContext(ProviderContext $context): self
    {
        if (!$this->providers->contains($context)) {
            $this->providers->add($context);
        }

        return $this;
    }

    public function removeProviderContext(ProviderContext $context): self
    {
        if ($this->providers->contains($context)) {
            $this->providers->remove($context);
        }

        return $this;
    }

    public function getLogoPath(): ?string
    {
        return $this->logoPath;
    }

    public function setLogoPath(?string $logoPath): self
    {
        $this->logoPath = $logoPath;
        return $this;
    }
}
