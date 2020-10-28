<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiFilter;
use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use ApiPlatform\Core\Annotation\ApiSubresource;
use App\Repository\VehicleTreeRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;
use ApiPlatform\Core\Bridge\Doctrine\Orm\Filter\SearchFilter;
use Symfony\Component\Serializer\Annotation\Groups;

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
 * @ApiFilter(SearchFilter::class, properties={"level": "exact", "name": "word_start", "energy.id": "exact", "energy.translations.name": "word_start"})
 * @ORM\Entity(repositoryClass=VehicleTreeRepository::class)
 */
class VehicleTree
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
     * @var VehicleTree
     * @ORM\ManyToOne(targetEntity="VehicleTree", inversedBy="children", cascade={"persist"})
     * @ApiSubresource()
     * @Groups({"vehicle:read", "vehicle:write"})
     */
    protected $parent;

    /**
     * @var Collection|VehicleTree[]
     * @ORM\OneToMany(targetEntity="VehicleTree", mappedBy="parent", cascade={"persist", "remove"})
     * @ApiSubresource()
     */
    protected $children;

    public function __construct()
    {
        $this->children = new ArrayCollection();
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

    public function setLevel(string $level): void
    {
        $this->level = $level;
    }

}
