<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiFilter;
use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use ApiPlatform\Core\Annotation\ApiSubresource;
use App\Repository\MechanicRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Filter\MechanicDistanceFilter;
use App\Dto\User as UserDto;

/**
 * @ApiResource(
 *     normalizationContext={"groups"={"read", "mechanic:read"}},
 *     denormalizationContext={"groups"={"write", "mechanic:write"}},
 *     collectionOperations={
 *         "get",
 *         "post"={
 *             "method"="POST",
 *             "input"=UserDto\MechanicProfile::class
 *         }
 *     },
 *     itemOperations={
 *         "get",
 *         "put"={
 *             "method"="PUT",
 *             "security"="is_granted('ROLE_ADMIN') or object.getUser() == user",
 *             "input"=UserDto\MechanicProfile::class
 *         }
 *     }
 * )
 * @ORM\Entity(repositoryClass=MechanicRepository::class)
 * @ApiFilter(MechanicDistanceFilter::class, properties={"user.address.geocoordinates"})
 */
class Mechanic
{
    use Traits\TimestampTrait;

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
     * @ORM\Column(type="text")
     * @Groups({"read", "write"})
     */
    protected $about;

    /**
     * @ORM\Column(type="integer", nullable=true)
     * @Groups({"read", "write"})
     */
    protected $years_of_experience;

    /**
     * @ORM\Column(type="integer", nullable=true)
     * @Groups({"read", "write"})
     */
    protected $working_range;

    /**
     * @ORM\Column(type="float", nullable=true)
     * @Groups({"read", "write"})
     */
    protected $avg_rating;

    /**
     * @var MechanicService[]|Collection
     * @ORM\ManyToMany(targetEntity="MechanicService", cascade={"persist", "remove"}, orphanRemoval=true)
     * @Groups({"mechanic:read", "mechanic:write"})
     * @ApiSubresource()
     */
    protected $services;

    /**
     * @var User
     * @ORM\OneToOne(targetEntity="User", inversedBy="mechanic")
     * @Groups({"mechanic:read"})
     */
    protected $user;

    public function __construct()
    {
        $this->services = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getYearsOfExperience(): ?int
    {
        return $this->years_of_experience;
    }

    public function setYearsOfExperience(?int $years_of_experience): self
    {
        $this->years_of_experience = $years_of_experience;

        return $this;
    }

    public function getWorkingRange(): ?int
    {
        return $this->working_range;
    }

    public function setWorkingRange(?int $working_range): self
    {
        $this->working_range = $working_range;

        return $this;
    }

    public function getAvgRating(): ?float
    {
        return $this->avg_rating;
    }

    public function setAvgRating(?float $avg_rating): self
    {
        $this->avg_rating = $avg_rating;

        return $this;
    }

    public function getUser(): User
    {
        return $this->user;
    }

    public function setUser(User $user): self
    {
        $this->user = $user;
        return $this;
    }

    public function getAbout(): string
    {
        return $this->about;
    }

    public function setAbout(string $about): self
    {
        $this->about = $about;
        return $this;
    }

    public function getServices(): Collection
    {
        return $this->services;
    }

    public function addService(MechanicService $service): self
    {
        if (!$this->services->contains($service)) {
            $this->services->add($service);
            $service->setMechanic($this);
        }
        return $this;
    }

    public function removeService(MechanicService $service): self
    {
        if ($this->services->contains($service)) {
            $this->services->remove($service);
        }
        return $this;
    }



}
